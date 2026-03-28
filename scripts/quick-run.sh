echo "Moving Into the right Directory"
cd ..

echo "Starting Looking"
terraform init

echo "Syntax Check"
terraform validate

echo "Seeing the future"
terraform plan

echo "Creating Infrastructure"
terraform apply -auto-approve