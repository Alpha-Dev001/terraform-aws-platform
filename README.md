# terraform-aws-platform

A learning project: a production-grade AWS platform structure, runnable locally
via [LocalStack](https://localstack.cloud/) — no AWS account or credit card needed.

## Quick Start

```bash
# 1. Start LocalStack (requires Docker)
docker run --rm -d -p 4566:4566 \
  -e SERVICES=ec2,s3,iam,sts,elbv2,autoscaling \
  localstack/localstack

# 2. Deploy the dev environment
cd environments/dev
terraform init
terraform plan
terraform apply

# 3. See what was created
terraform output

# 4. Clean up
terraform destroy
```

## Project Structure

```
terraform-aws-platform/
├── environments/          # One folder per environment
│   ├── dev/               # terraform apply runs here
│   ├── staging/
│   └── prod/
├── modules/               # Reusable building blocks
│   ├── networking/        # VPC, subnets, routing
│   ├── security/          # Security groups, IAM
│   ├── compute/           # EC2, ASG, ALB
│   └── storage/           # S3
└── docs/
    ├── architecture.md    # System design
    └── learning-notes.md  # Terraform concept explanations
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- [Docker](https://docs.docker.com/get-docker/) (for LocalStack)

## Docs

- [Architecture](docs/architecture.md)
- [Learning Notes](docs/learning-notes.md) 
