<div align="center">

# 🌍 Geo-Routed Multi-Origin Web Infrastructure on AWS

**Production-style edge routing with CloudFront, Lambda@Edge, Application Load Balancers, and EC2**

<br/>


<!-- Geo-Routed-Multi-Origin-Web-Infrastructure-on-AWS  -->


<img width="1407" height="768" alt="trio" src="https://github.com/user-attachments/assets/257180ff-d39d-4094-b56e-fec975e87fe9" />

<br/>
<br/>

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-Terraform%20Language-844FBA?style=for-the-badge)
![CloudFront](https://img.shields.io/badge/CloudFront-FF9900?style=for-the-badge&logo=amazonaws&logoColor=black)
![Lambda@Edge](https://img.shields.io/badge/Lambda@Edge-FF9900?style=for-the-badge&logo=awslambda&logoColor=white)
![ALB](https://img.shields.io/badge/Application%20Load%20Balancer-8C4FFF?style=for-the-badge)
![EC2](https://img.shields.io/badge/EC2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)
![VPC](https://img.shields.io/badge/Amazon%20VPC-Networking-0EA5E9?style=for-the-badge)
![Subnets](https://img.shields.io/badge/Public%20Subnets-MultiAZ-2563EB?style=for-the-badge)
![Internet Gateway](https://img.shields.io/badge/Internet%20Gateway-Public%20Access-0F766E?style=for-the-badge)
![Security Groups](https://img.shields.io/badge/Security%20Groups-Stateful%20Firewall-16A34A?style=for-the-badge)
![IAM](https://img.shields.io/badge/IAM-Least%20Privilege-DD6B20?style=for-the-badge)
![Geo Routing](https://img.shields.io/badge/Geo%20Routing-Viewer%20Location-14B8A6?style=for-the-badge)
![Multi Origin](https://img.shields.io/badge/Multi--Origin-CloudFront-7C3AED?style=for-the-badge)
![Edge Computing](https://img.shields.io/badge/Edge%20Computing-Low%20Latency-DC2626?style=for-the-badge)
![CDN](https://img.shields.io/badge/CDN-Global%20Delivery-0284C7?style=for-the-badge)
![Load Balancing](https://img.shields.io/badge/Load%20Balancing-Highly%20Available-9333EA?style=for-the-badge)
![Amazon Linux](https://img.shields.io/badge/Amazon%20Linux-EC2%20Web%20Hosts-F59E0B?style=for-the-badge)
![Infrastructure as Code](https://img.shields.io/badge/Infrastructure%20as%20Code-Automated-4F46E5?style=for-the-badge)
![Portfolio Project](https://img.shields.io/badge/Project-Portfolio-22C55E?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production%20Inspired-success?style=for-the-badge)

</div>

---

## Overview

This project deploys a **geo-routed multi-origin web architecture on AWS** using Terraform.

A user hits a single **CloudFront distribution**, and **Lambda@Edge** decides which backend origin to use based on viewer location metadata. The request is then forwarded to one of two **Application Load Balancers**, which send traffic to separate **EC2 web servers**.

This demonstrates:

- CDN and edge routing concepts
- Lambda@Edge origin selection
- Multi-origin CloudFront design
- Load balancing with ALB target groups
- Public VPC networking on AWS
- Infrastructure as Code with Terraform

---
# DEMO

# USA

https://github.com/user-attachments/assets/b210304c-fcb3-4329-93ca-afcb773b4ed8

# BRAZIL
https://github.com/user-attachments/assets/3492f7c2-0966-43d8-91d3-71a3739647dd

## What this builds

✅ A custom **VPC**  
✅ **2 public subnets** across different Availability Zones  
✅ An **Internet Gateway** and route table for public access  
✅ Security groups for **ALB** and **EC2**  
✅ **2 EC2 instances** serving different web pages  
✅ **2 Application Load Balancers**  
✅ **2 target groups** with health checks  
✅ A **Lambda@Edge** function for geo-based origin routing  
✅ A **CloudFront distribution** with custom cache/origin request policies  
✅ A default **`.cloudfront.net`** endpoint for global access  

---

## CORE AWS RESOURCES

---

## CORE AWS RESOURCES

| Service | Role in Architecture |
| :--- | :--- |
| **Amazon CloudFront** | Global CDN and primary entry point. |
| **AWS Lambda@Edge** | Executes routing logic at edge locations based on viewer geography. |
| **Application Load Balancer (ALB)** | Distributes traffic to the designated regional EC2 targets. |
| **Amazon EC2** | Hosts the web servers/applications for the specific regions. |
| **Amazon VPC** | Provides the isolated network infrastructure, subnets, and routing. |

---

##  PROJECT STRUCTURE

```text
.
├── build/
│   └── geo_router.zip
├── lambda/
│   └── geo_router.js.tftpl
├── scripts/
│   ├── ec2-webpage.sh
│   └── ec2-webpage2.sh
│   └── quick-run.sh
├── .gitignore
├── README.md
├── main.tf
├── output.tf
├── terraform.lock.hcl
└── var.tf
```

#   Quick start

1. Clone the repository

2. git clone https://github.com7twoduo/Geo-Routed-Multi-Origin-Web-Infrastructure-on-AWS.git

3. cd Geo-Routed-Multi-Origin-Web-Infrastructure-on-AWS

4. Review the backend config

Update the backend bucket if needed:

```text

terraform {
  backend "s3" {
    bucket = "YOUR_BACKEND_BUCKET"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
```
5. cd Geo-Routed-Multi-Origin-Web-Infrastructure-on-AWS/scripts
```text
In the terminal, run ./quick-apply.sh
```


After deployment, grab the CloudFront domain from Terraform output and open it in a browser.

It should look like:

https://xxxxxxxxxxxx.cloudfront.net

---

## 🧪 Validation & Testing

To verify that the **Lambda@Edge** routing logic is correctly identifying viewer location and dynamically shifting origins, follow these steps:

### **1. Establish a Baseline (US Origin)**
Access the CloudFront distribution link directly from your browser. Since the default routing points to the North American region, you will be directed to the **US Server**.

### **2. Simulate Global Traffic (Brazil Origin)**
To test the geo-routing logic, you need to simulate a request originating from South America:
* **Action:** Enable a VPN (such as **UrbanVPN**) and set your exit node to **Brazil**.
* **Result:** This changes your request metadata to reflect a Brazilian IP address.

### **3. Verify Edge Execution**
Refresh the CloudFront URL. The Lambda@Edge function intercepts the request, identifies the `CloudFront-Viewer-Country` header as `BR`, and dynamically rewrites the origin request to the **Brazil ALB**.

> **✅ Success Criteria:** You should now see the unique web content served from the Brazil-based EC2 instance, proving the global traffic management and edge logic are fully functional.

---

## 🚀 Expected Behavior

1. **Global Entry Point:** Users hit a single **CloudFront** distribution endpoint.
2. **Edge Logic:** A **Lambda@Edge** function intercepts the request and evaluates the viewer's location.
3. **Dynamic Routing:** Traffic is intelligently forwarded to the appropriate regional backend:
    * 🇧🇷 **Brazil Origin:** Routed to the Brazil Application Load Balancer (ALB).
    * 🇺🇸 **US / Default Origin:** Routed to the US Application Load Balancer (ALB).
4. **Processing:** Each ALB forwards traffic to its dedicated **EC2 instance**, serving a region-specific response.

---

## ♻️ Tear Down

To decommission the infrastructure and avoid unnecessary AWS costs, navigate to the root directory containing `main.tf` and run:

```bash
terraform destroy
```

## 🛡️ Security Architecture

* **Edge Defense:** CloudFront serves as the hardened public entry point.
* **Identity & Access:** Granular **IAM Roles** power the Lambda@Edge execution.
* **Network Isolation:** Tiered **Security Groups** protect both the ALBs and the EC2 instances.
* **Path Separation:** Logic-based routing ensures backend origins remain isolated.

---

## 🏗️ Production Roadmap (Current Demo Limitations)

*This project is built as a portfolio-ready proof of concept. To transition to a full-scale production environment, the following enhancements are recommended:*

* **Enhanced Lockdown:** Restrict EC2 HTTP traffic strictly to ALB Security Group IDs.
* **Access Control:** Replace open SSH with **AWS Systems Manager (SSM)** or a Bastion host.
* **Encryption:** Implement **HTTPS** on ALBs and attach a custom domain via **AWS Certificate Manager (ACM)**.
* **Edge Security:** Deploy **AWS WAF** in front of CloudFront to mitigate Layer 7 attacks.
* **High Availability:** Replace single-instance EC2s with **Auto Scaling Groups (ASG)**.
* **Observability:** Integrate structured logging (CloudWatch) and real-time alerting.

---

## 🧠 Engineering Challenges & Solutions

| Problem | Technical Resolution |
| :--- | :--- |
| **Lambda@Edge Packaging** | Automated the build process to render and **ZIP** JavaScript templates into deployable artifacts during the Terraform apply. |
| **Origin Rewriting** | Configured **CloudFront Origin Request** events to handle custom routing logic that native CloudFront behaviors don't support out-of-the-box. |
| **Geo-Location Precision** | Optimized **Cache & Origin Request Policies** to ensure CloudFront viewer headers (like `CloudFront-Viewer-Country`) are correctly forwarded. |
| **State Management** | Implemented an **S3 Backend** for Terraform with considerations for local lockfile synchronization across different workflows. |

---

## 🚀 Why This Project Matters

This project highlights **production-inspired AWS edge architecture** and demonstrates how modern cloud services can be combined to build intelligent, scalable, and globally distributed routing systems.

Instead of stopping at a basic deployment, this repository focuses on **real infrastructure patterns** used in performance-sensitive and traffic-aware environments.

### ✨ What This Project Demonstrates

- 🌐 **AWS networking and traffic flow design**
- ⚡ **Edge computing with Lambda@Edge**
- 📦 **CDN behavior and request routing with CloudFront**
- 🧠 **Origin selection and request manipulation at the edge**
- 🔀 **Load balancing across backend services**
- 🏗️ **Terraform-based infrastructure provisioning**
- 📈 **Production-inspired architecture thinking**

---

## 🛠️ Built With

- **Terraform**
- **Amazon CloudFront**
- **Lambda@Edge**
- **Application Load Balancers**
- **Amazon EC2**

---

## 🎯 Project Objective

The goal of this repository is to demonstrate **practical cloud engineering skills** through a production-inspired AWS edge routing solution.

It is designed to showcase more than just deployment — it emphasizes:

- intelligent request routing  
- edge-side logic  
- scalable backend delivery  
- repeatable Infrastructure as Code  
- real-world architectural decision-making  

---

## 👨‍💻 About the Author

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Inter&weight=600&size=22&pause=1000&color=58A6FF&center=true&vCenter=true&width=760&lines=Cloud+Engineer+focused+on+AWS%2C+Terraform%2C+and+automation;Building+production-inspired+infrastructure+projects;Turning+cloud+concepts+into+real-world+implementations" alt="Typing SVG" />
</p>

<p align="center">
  I build hands-on cloud projects designed to reflect practical engineering work rather than simple demos.
  My focus is on <b>AWS infrastructure</b>, <b>Infrastructure as Code</b>, <b>automation</b>, <b>security-minded design</b>,
  and <b>real implementation patterns</b> that translate into production environments.
</p>

<p align="center">
  Through projects like this, I aim to demonstrate the ability to design, provision, and integrate modern cloud services
  in ways that are scalable, structured, and operationally relevant.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/AWS-Architecting-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white" />
  <img src="https://img.shields.io/badge/Terraform-Infrastructure-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Cloud-Engineering-1F6FEB?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Automation-Building-success?style=for-the-badge" />
</p>

<p align="center">
  <a href="https://www.linkedin.com/in/gavin-fogwe/">
    <img src="https://img.shields.io/badge/LinkedIn-Let's%20Connect-blue?style=for-the-badge&logo=linkedin" />
  </a>
  <a href="https://github.com/gavinxenon0-arch">
    <img src="https://img.shields.io/badge/GitHub-See%20More%20Projects-black?style=for-the-badge&logo=github" />
  </a>
  <a href="https://gavinfogwe.win/">
    <img src="https://img.shields.io/badge/Portfolio-Explore-orange?style=for-the-badge&logo=googlechrome&logoColor=white" />
  </a>
</p>
