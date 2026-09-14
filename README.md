# Production Three-Tier Web App

Highly available three-tier web application on ECS Fargate with RDS PostgreSQL, ElastiCache Redis, and comprehensive observability and security across two Availability Zones.

![CloudCrew AI](https://img.shields.io/badge/Generated%20By-CloudCrew%20AI-02C39A)
![IaC Engine](https://img.shields.io/badge/IaC-Terraform%20%2B%20Pulumi-blue)
![Region](https://img.shields.io/badge/Region-us-east-1-orange)

## Architecture

📐 [View Architecture Diagram](https://github.com/cloudcrewai/cloudcrew-deployments/blob/cloudcrew-fd07b63f/docs/architecture.png)

## Overview

| Property | Value |
|---|---|
| Project | `three-tier-web-app` |
| Environment | `production` |
| Region | `us-east-1` |
| IaC Engine | Terraform + Pulumi |
| Availability Zones | 2 |
| Estimated Monthly Cost | $1,081.93 |
| Session ID | `fd07b63f-f256-4e1d-bd15-f115984e040d` |

## Components

| Component | Type | Description |
|---|---|---|
| Route53 DNS | `route53` |  |
| ACM Certificate | `acm` |  |
| App VPC | `vpc` |  |
| Internet Gateway | `internet gateway` |  |
| NAT Gateway AZ-A | `nat gateway` |  |
| NAT Gateway AZ-B | `nat gateway` |  |
| Public Subnet AZ-A | `public subnet` |  |
| Public Subnet AZ-B | `public subnet` |  |
| Private Subnet AZ-A | `private subnet` |  |
| Private Subnet AZ-B | `private subnet` |  |
| Data Subnet AZ-A | `private subnet` |  |
| Data Subnet AZ-B | `private subnet` |  |
| Application Load Balancer | `alb` |  |
| ECS Fargate Service | `ecs` |  |
| ECR Repository | `ecr` |  |
| KMS Key for RDS | `kms` |  |
| RDS PostgreSQL Primary | `rds` |  |
| RDS PostgreSQL Standby | `rds` |  |
| ElastiCache Redis Primary | `elasticache` |  |
| ElastiCache Redis Replica | `elasticache` |  |
| S3 Application Assets | `s3` |  |
| S3 CloudTrail Logs | `s3` |  |
| S3 ALB Access Logs | `s3` |  |
| CloudTrail Multi-Region | `cloudtrail` |  |
| KMS Key for CloudWatch Logs | `kms` |  |
| CloudWatch Log Groups | `cloudwatch` |  |
| CloudWatch Alarms | `cloudwatch` |  |
| KMS Key for Secrets Manager | `kms` |  |
| Secrets Manager | `secrets manager` |  |
| KMS Key for ALB Logs | `kms` |  |

## Cost Breakdown

| Service | Monthly Cost |
|---|---|
| nat gateway | $32.85 |
| nat gateway | $32.85 |
| alb | $16.43 |
| ecs | $36.04 |
| ecr | $1.00 |
| kms | $1.00 |
| rds | $328.50 |
| rds | $328.50 |
| elasticache | $150.38 |
| elasticache | $150.38 |
| kms | $1.00 |
| kms | $1.00 |
| secrets manager | $1.00 |
| kms | $1.00 |
| **Total** | **$1,081.93** |

## Security

Shield scan: **✅ PASSED**
- Critical: 0 | High: 7 | Medium: 32 | Low: 11

## Deployment

> ⚠️ **Always review the plan before applying.** Run `terraform plan` and read the
> output before `terraform apply`. Prefer your CI/CD pipeline with approval gates for production.

### Step 1 — Bootstrap the Terraform state backend (once per AWS account)

State is stored in S3 with DynamoDB locking, in **your own** AWS account. Run the
`CloudCrew AI — Bootstrap State Backend` workflow once, from the Actions tab of this
repo (`workflow_dispatch`, no inputs needed). It creates the bucket/lock table under
*your* credentials and publishes their names as repo variables the deploy workflow
below reads — running it manually via the AWS CLI instead will create the same
resources but will NOT publish those variables, and the deploy workflow will refuse
to run without them.

### Step 2 — Apply in phase order

This deployment uses a 3-phase structure. **Apply phases in order** — each
phase consumes outputs (via remote state) from the previous one.

**Phase: Networking**
```bash
cd terraform/01-networking
terraform init
terraform plan -out=tfplan
terraform apply tfplan
cd ../..
```

**Phase: Data**
```bash
cd terraform/02-data
terraform init
terraform plan -out=tfplan
terraform apply tfplan
cd ../..
```

**Phase: Compute**
```bash
cd terraform/03-compute
terraform init
terraform plan -out=tfplan
terraform apply tfplan
cd ../..
```

## Documentation

| Document | Description |
|---|---|
| [Architecture Diagram](docs/architecture.png) | Visual architecture overview |
| [Rollback Guide](docs/rollback.md) | Step-by-step rollback instructions |
| [Primary Compute Platform Selection](docs/adr/ADR-001-primary-compute-platform-selection.md) | Architecture Decision Record |
| [Database Engine Selection](docs/adr/ADR-002-database-engine-selection.md) | Architecture Decision Record |
| [Network Topology Design](docs/adr/ADR-003-network-topology-design.md) | Architecture Decision Record |
| [Security Posture Summary](docs/adr/ADR-004-security-posture-summary.md) | Architecture Decision Record |
| [Cost Optimisation Strategy](docs/adr/ADR-005-cost-optimisation-strategy.md) | Architecture Decision Record |
| [Route53 DNS](docs/runbooks/RUNBOOK-OPS-001-route53-dns.md) | Operational Runbook |
| [ACM Certificate](docs/runbooks/RUNBOOK-OPS-002-acm-certificate.md) | Operational Runbook |
| [App VPC](docs/runbooks/RUNBOOK-OPS-003-app-vpc.md) | Operational Runbook |
| [NAT Gateway AZ-A](docs/runbooks/RUNBOOK-OPS-004-nat-gateway-az-a.md) | Operational Runbook |
| [NAT Gateway AZ-B](docs/runbooks/RUNBOOK-OPS-005-nat-gateway-az-b.md) | Operational Runbook |
| [Public Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-006-public-subnet-az-a.md) | Operational Runbook |
| [Public Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-007-public-subnet-az-b.md) | Operational Runbook |
| [Private Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-008-private-subnet-az-a.md) | Operational Runbook |

---
*Generated by [CloudCrew AI](https://cloudcrewai.com) — Session `fd07b63f-f256-4e1d-bd15-f115984e040d`*