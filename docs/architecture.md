# Architecture Overview

## What This Project Builds

A three-tier web application platform on AWS (simulated locally via LocalStack),
with separate isolated environments for dev, staging, and production.

```
                        ┌─────────────────────────────────────────┐
                        │              AWS / LocalStack           │
                        │                                         │
  Internet Traffic      │   ┌──────────┐     ┌─────────────────┐  │
  ──────────────────────┼──►│   ALB    │────►│ Auto Scaling    │  │
                        │   │ (public) │     │ Group (private) │  │
                        │   └──────────┘     └────────┬────────┘  │
                        │                             │           │
                        │                    ┌────────▼────────┐  │
                        │                    │   S3 Bucket     │  │
                        │                    │ (app storage)   │  │
                        │                    └─────────────────┘  │
                        └─────────────────────────────────────────┘
```
## Module Responsibilities

| Module      | Creates                                        | Why                                      |
|-------------|------------------------------------------------|------------------------------------------|
| networking  | VPC, subnets, IGW, route tables                | Defines the isolated network boundaries  |
| security    | Security groups, IAM role + profile            | Controls traffic and AWS API permissions |
| storage     | S3 bucket, versioning, lifecycle rules         | Persists application data                |
| compute     | Launch Template, ASG, ALB, Target Group        | Runs the application                     |

## Data Flow Between Modules

```
networking  ──► vpc_id, subnet_ids ──► security
                                  └──► compute

security    ──► sg_ids, iam_profile ──► compute

storage     (independent)

compute     ──► alb_dns_name ──► outputs
```

## Environment Differences

| Setting          | dev        | staging    | prod       |
|------------------|------------|------------|------------|
| instance_type    | t3.micro   | t3.small   | t3.medium  |
| min_instances    | 1          | 1          | 2          |
| max_instances    | 2          | 3          | 6          |
| enable_versioning| false      | false      | true       |
| vpc_cidr         | 10.0.x.x   | 10.1.x.x   | 10.2.x.x   |

Each environment uses its own VPC CIDR to prevent IP conflicts if ever connected.

## LocalStack Setup

Run LocalStack before `terraform apply`:

```bash
docker run --rm -d \
  -p 4566:4566 \
  -e SERVICES=ec2,s3,iam,sts,elbv2,autoscaling \
  localstack/localstack
```
