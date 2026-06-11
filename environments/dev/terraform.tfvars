aws_region   = "us-east-1"
project_name = "myapp"
environment  = "dev"

# Network layout
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# Compute — keep it minimal for dev
instance_type = "t3.micro"
min_instances = 1
max_instances = 2

# Storage — no versioning needed in dev
enable_versioning = false

tags = {
  Owner      = "your-name"
  CostCenter = "engineering"
}
