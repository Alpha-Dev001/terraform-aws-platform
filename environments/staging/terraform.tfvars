aws_region   = "us-east-1"
project_name = "myapp"
environment  = "staging"

vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]

instance_type = "t3.small"
min_instances = 1
max_instances = 3

enable_versioning = false

tags = {
  Owner      = "your-name"
  CostCenter = "engineering"
}
