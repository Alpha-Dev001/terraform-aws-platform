# Prod: bigger instances, more capacity, versioning enabled for safety.

aws_region   = "us-east-1"
project_name = "myapp"
environment  = "prod"

vpc_cidr             = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24"]

instance_type = "t3.medium"
min_instances = 2
max_instances = 6

# Always enable versioning in prod — it's your safety net
enable_versioning = true

tags = {
  Owner      = "your-name"
  CostCenter = "engineering"
}
