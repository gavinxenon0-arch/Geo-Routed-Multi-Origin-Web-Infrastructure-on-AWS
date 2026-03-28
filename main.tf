terraform {
  required_version = "~> 1.14.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7.1"
    }
  }

  backend "s3" {
    bucket = "lion-rari" # Put your S3 bucket here
    key    = "terraform.tfstate"
    region = "us-east-1"
    # use_lockfile = true     # This is still buggy, use hcl backend or dynamodb table(it is depreciated)
  }
}

provider "aws" {
  region = "us-east-1"
}


# The VPC
resource "aws_vpc" "shadows" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "2-shadows"
  }
}
# The subnets
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.shadows.id
  cidr_block              = var.subnet_cidr1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "2-shadows-subnet"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.shadows.id
  cidr_block              = var.subnet_cidr2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "2-shadows-subnet"
  }
}
# The internet gateway for internet access to your VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.shadows.id

  tags = {
    Name = "2-shadows-internet-gateway"
  }
}
# The Route Table and Route associations
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.shadows.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "2-shadows-route-table"
  }
}

resource "aws_route_table_association" "route-table" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route-table.id
}
resource "aws_route_table_association" "route-table2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route-table.id
}


# SG for EC2 and ALB
resource "aws_security_group" "EC2" {
  name        = "EC2-security-group"
  description = "Security Group for the EC2 instance"
  vpc_id      = aws_vpc.shadows.id
}


resource "aws_security_group" "ALB" {
  name        = "EC2-security-group-alb"
  description = "Security Group for the EC2 instance"
  vpc_id      = aws_vpc.shadows.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4_alb" {
  security_group_id = aws_security_group.ALB.id
  cidr_ipv4         = var.public_access_cidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv4_alb" {
  security_group_id = aws_security_group.ALB.id
  cidr_ipv4         = var.public_access_cidr
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.EC2.id
  cidr_ipv4         = var.public_access_cidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.EC2.id
  cidr_ipv4         = var.public_access_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv4" {
  security_group_id = aws_security_group.EC2.id
  cidr_ipv4         = var.public_access_cidr
  ip_protocol       = "-1" # semantically equivalent to all ports
}

##################################################################################        BR ALB And Instance
# The Ec2 instance for the ALB
resource "aws_instance" "first_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet1.id
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/ec2-webpage.sh")
  security_groups             = [aws_security_group.EC2.id]

}
# The ALB
resource "aws_lb" "alb_us" {
  name               = "alb-us-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB.id]
  subnets = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]
}
# The target group and health check the ALB
resource "aws_lb_target_group" "tg_us" {
  name        = "tg-us-web"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.shadows.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200-399"
  }
}
# The target group instance attachement
resource "aws_lb_target_group_attachment" "us_instance" {
  target_group_arn = aws_lb_target_group.tg_us.arn
  target_id        = aws_instance.first_instance.id
  port             = 80
}
# The listener for the ALB to Route Traffic to the target group
resource "aws_lb_listener" "us_http" {
  load_balancer_arn = aws_lb.alb_us.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_us.arn
  }
}



##################################################################################        US ALB And Instance
# Same Rules for the stuff above to the stuff below
resource "aws_instance" "second_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet2.id
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/ec2-webpage2.sh")
  security_groups             = [aws_security_group.EC2.id]
}
resource "aws_lb" "alb_br" {
  name               = "alb-br-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB.id]
  subnets = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]
}

resource "aws_lb_target_group" "tg_br" {
  name        = "tg-br-web"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.shadows.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }
}

resource "aws_lb_target_group_attachment" "br_instance" {
  target_group_arn = aws_lb_target_group.tg_br.arn
  target_id        = aws_instance.second_instance.id
  port             = 80
}

resource "aws_lb_listener" "br_http" {
  load_balancer_arn = aws_lb.alb_br.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_br.arn
  }
}



#################################################       CDN 2 origins and edge function #######################################
#################################################                                       #######################################
# This will be good to integrate for future deployment
variable "origin_verify" {
  type        = string
  description = "secret header value"
  default     = ""
}
# This is to pass the origin 1 and 2 to the lambda function that shall do the routing based on location to the predefined alb for USA and Brazil
locals {
  geo_router_js = templatefile("${path.module}/lambda/geo_router.js.tftpl", {
    origin_br      = local.origin1
    origin_default = local.origin2
    origin_verify  = var.origin_verify
  })
}
#Converts the python file to a zip file which can be uploaded to lambda. For some reason, lambda is designed that way and this is just a solution to that problem.
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/build/geo_router.zip"

  source {
    content  = local.geo_router_js
    filename = "geo_router.js"
  }
}
# This is role for the lambda function
resource "aws_iam_role" "lambda_edge_role" {
  name = "lambda-edge-geo-router-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
# This is the policy I attach to the role
resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_edge_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
#This is the lambda function for the edge furnction
resource "aws_lambda_function" "geo_router" {
  function_name    = "geo-router-node-js"
  role             = aws_iam_role.lambda_edge_role.arn
  handler          = "geo_router.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  publish          = true
}


# This is the cache policy that reveals the location of a user so that the lambda function can use that data to configure routing between two or more locations.
resource "aws_cloudfront_cache_policy" "geo_country_cache" {
  name        = "geo-country-cache-policy-demo"
  comment     = "Cache key includes viewer country for geo routing"
  default_ttl = 60
  max_ttl     = 3600
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = [
          "CloudFront-Viewer-Country"
        ]
      }
    }
  }
}


# This reveals the city of the incoming request to the cloudfront destro.
resource "aws_cloudfront_origin_request_policy" "geo_headers" {
  name    = "geo-routing-policy-demo"
  comment = "Forward city to origin, country already comes from cache policy"
  headers_config {
    header_behavior = "whitelist"

    headers {
      items = [
        "CloudFront-Viewer-City",
        #"CloudFront-Viewer-Country"
      ]
    }
  }

  cookies_config {
    cookie_behavior = "none"
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}






# This is just to make it easy to change and more programmable for later changes.
locals {
  origin1 = aws_lb.alb_br.dns_name
  origin2 = aws_lb.alb_us.dns_name
}





# This is the cloudfront destribution that integrates all the necessary changes for this use case. I did not put too many configurations so it is simple and easy to use.
resource "aws_cloudfront_distribution" "geo_demo" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Geo routing between origin 1 and origin 2"

  # You can keep two declared origins for clarity, even though Lambda@Edge
  # can dynamically rewrite the origin on origin-request.
  origin {
    domain_name = local.origin1
    origin_id   = "origin-1"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = local.origin2
    origin_id   = "origin-2"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "origin-1"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = aws_cloudfront_cache_policy.geo_country_cache.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.geo_headers.id

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.geo_router.qualified_arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}