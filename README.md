# Production Three-Tier Web App

Highly available three-tier web application in us-east-1 across 2 AZs, featuring an ALB with HTTPS, ECS Fargate services, Multi-AZ RDS PostgreSQL, ElastiCache Redis, S3 with SSE-KMS, and comprehensive CloudWatch monitoring with KMS customer-managed keys. Note: A custom domain and ACM certificate must be provided by the customer for HTTPS with a custom domain.

![CloudCrew AI](https://img.shields.io/badge/Generated%20By-CloudCrew%20AI-02C39A)
![IaC Engine](https://img.shields.io/badge/IaC-Terraform%20%2B%20Pulumi-blue)
![Region](https://img.shields.io/badge/Region-us-east-1-orange)

## Architecture

📐 [View Architecture Diagram](https://github.com/cloudcrewai/cloudcrew-deployments/blob/cloudcrew-3f14a256/docs/architecture.png)

## Overview

| Property | Value |
|---|---|
| Project | `three-tier-web-app` |
| Environment | `production` |
| Region | `us-east-1` |
| IaC Engine | Terraform + Pulumi |
| Availability Zones | 2 |
| Estimated Monthly Cost | $1,085.93 |
| Session ID | `3f14a256-1cae-45ea-8ae1-2624dc19e4b2` |

## Components

| Component | Type | Description |
|---|---|---|
| App VPC | `vpc` |  |
| Internet Gateway | `internet gateway` |  |
| NAT Gateway AZ-A | `nat gateway` |  |
| NAT Gateway AZ-B | `nat gateway` |  |
| Public Subnet AZ-A | `public subnet` |  |
| Public Subnet AZ-B | `public subnet` |  |
| Private Subnet AZ-A | `private subnet` |  |
| Private Subnet AZ-B | `private subnet` |  |
| Application Load Balancer | `alb` |  |
| WAF Web ACL | `waf` |  |
| ECS Fargate Service | `ecs` |  |
| ECR Repository | `ecr` |  |
| RDS PostgreSQL Primary | `rds` |  |
| RDS PostgreSQL Standby | `rds` |  |
| ElastiCache Redis Primary | `elasticache` |  |
| ElastiCache Redis Replica | `elasticache` |  |
| S3 Application Assets | `s3` |  |
| S3 ALB Access Logs | `s3` |  |
| KMS Key for S3 | `kms` |  |
| KMS Key for ALB Logs | `kms` |  |
| KMS Key for CloudWatch Logs | `kms` |  |
| Secrets Manager | `secrets manager` |  |
| CloudWatch Logs & Alarms | `cloudwatch` |  |

## Cost Breakdown

| Service | Monthly Cost |
|---|---|
| nat gateway | $32.85 |
| nat gateway | $32.85 |
| alb | $16.43 |
| waf | $5.00 |
| ecs | $36.04 |
| ecr | $1.00 |
| rds | $328.50 |
| rds | $328.50 |
| elasticache | $150.38 |
| elasticache | $150.38 |
| kms | $1.00 |
| kms | $1.00 |
| kms | $1.00 |
| secrets manager | $1.00 |
| **Total** | **$1,085.93** |

## Security

Shield scan: **✅ PASSED**
- Critical: 0 | High: 4 | Medium: 17 | Low: 7

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
| [Security Posture Assessment](docs/adr/ADR-004-security-posture-assessment.md) | Architecture Decision Record |
| [Cost Optimisation Considerations](docs/adr/ADR-005-cost-optimisation-considerations.md) | Architecture Decision Record |
| [App VPC](docs/runbooks/RUNBOOK-OPS-001-app-vpc.md) | Operational Runbook |
| [Internet Gateway](docs/runbooks/RUNBOOK-OPS-002-internet-gateway.md) | Operational Runbook |
| [NAT Gateway AZ-A](docs/runbooks/RUNBOOK-OPS-003-nat-gateway-az-a.md) | Operational Runbook |
| [NAT Gateway AZ-B](docs/runbooks/RUNBOOK-OPS-004-nat-gateway-az-b.md) | Operational Runbook |
| [Public Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-005-public-subnet-az-a.md) | Operational Runbook |
| [Public Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-006-public-subnet-az-b.md) | Operational Runbook |
| [Private Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-007-private-subnet-az-a.md) | Operational Runbook |
| [Private Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-008-private-subnet-az-b.md) | Operational Runbook |

---
*Generated by [CloudCrew AI](https://cloudcrewai.com) — Session `3f14a256-1cae-45ea-8ae1-2624dc19e4b2`*