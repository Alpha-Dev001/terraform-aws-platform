output "alb_dns_name"    { value = module.compute.alb_dns_name }
output "vpc_id"          { value = module.networking.vpc_id }
output "app_bucket_name" { value = module.storage.bucket_name }
