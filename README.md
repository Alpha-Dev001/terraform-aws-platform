# Terraform AWS Platform

Infrastructure as Code project built using Terraform.

## Goals

- Learn Terraform professionally
- Build reusable modules
- Support multiple environments
- Prepare for AWS deployments

## Project Structure

terraform-aws-platform/
│
├── README.md
├── .gitignore
├── versions.tf
├── providers.tf
├── variables.tf
├── outputs.tf
│
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   │
│   ├── staging/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   │
│   └── prod/
│       ├── main.tf
│       ├── terraform.tfvars
│       └── outputs.tf
│
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── security/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── storage/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── docs/
    ├── architecture.md
    └── learning-notes.md
