# Tell Terraform where to find the provider config
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
    random = { source = "hashicorp/random"; version = "~> 3.0" }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = "test"
  secret_key = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    ec2            = "http://localhost:4566"
    s3             = "http://localhost:4566"
    iam            = "http://localhost:4566"
    sts            = "http://localhost:4566"
    elbv2          = "http://localhost:4566"
    autoscaling    = "http://localhost:4566"
  }
}

#NETWORKING
module "networking" {
  source = "../../modules/networking"   # relative path to the module folder

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

# ── SECURITY ─────
module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id       # output from networking module
  vpc_cidr     = module.networking.vpc_cidr_block
  tags         = local.common_tags
}

# ── STORAGE 
module "storage" {
  source = "../../modules/storage"

  project_name      = var.project_name
  environment       = var.environment
  enable_versioning = var.enable_versioning
  tags              = local.common_tags
}

# ── COMPUTE 
module "compute" {
  source = "../../modules/compute"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  private_subnet_ids  = module.networking.private_subnet_ids
  web_sg_id           = module.security.web_sg_id
  alb_sg_id           = module.security.alb_sg_id
  ec2_instance_profile = module.security.ec2_instance_profile
  instance_type       = var.instance_type
  min_instances       = var.min_instances
  max_instances       = var.max_instances
  tags                = local.common_tags
}

# ── LOCAL VALUES 
locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}
