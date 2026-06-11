output "vpc_id" {
  description = "ID of the VPC created by the networking module"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "web_sg_id" {
  description = "Security Group ID for web-tier EC2 instances"
  value       = module.security.web_sg_id
}

output "alb_sg_id" {
  description = "Security Group ID for the Application Load Balancer"
  value       = module.security.alb_sg_id
}

output "app_bucket_name" {
  description = "Name of the S3 bucket used by the application"
  value       = module.storage.bucket_name
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.autoscaling_group_name
}
