# Production Microservices Platform

Highly available, production-grade microservices platform across 3 Availability Zones using ECS Fargate, API Gateway, internal ALB, Aurora PostgreSQL, ElastiCache Redis, Cloud Map, and Secrets Manager. Includes comprehensive observability and KMS encryption.

![CloudCrew AI](https://img.shields.io/badge/Generated%20By-CloudCrew%20AI-02C39A)
![IaC Engine](https://img.shields.io/badge/IaC-Terraform%20%2B%20Pulumi-blue)
![Region](https://img.shields.io/badge/Region-us-east-1-orange)

## Architecture

📐 [View Architecture Diagram](https://github.com/cloudcrewai/cloudcrew-deployments/blob/cloudcrew-2a070023/docs/architecture.png)

## Overview

| Property | Value |
|---|---|
| Project | `microservices-platfo` |
| Environment | `production` |
| Region | `us-east-1` |
| IaC Engine | Terraform + Pulumi |
| Availability Zones | 3 |
| Session ID | `2a070023-0db0-4387-aa22-a5ac6218424e` |

## Components

| Component | Type | Description |
|---|---|---|
| App VPC | `vpc` |  |
| Internet Gateway | `internet gateway` |  |
| NAT Gateway AZ-A | `nat gateway` |  |
| NAT Gateway AZ-B | `nat gateway` |  |
| NAT Gateway AZ-C | `nat gateway` |  |
| Public Subnet AZ-A | `public subnet` |  |
| Public Subnet AZ-B | `public subnet` |  |
| Public Subnet AZ-C | `public subnet` |  |
| Private Subnet AZ-A | `private subnet` |  |
| Private Subnet AZ-B | `private subnet` |  |
| Private Subnet AZ-C | `private subnet` |  |
| Database Subnet AZ-A | `private subnet` |  |
| Database Subnet AZ-B | `private subnet` |  |
| Database Subnet AZ-C | `private subnet` |  |
| WAF | `waf` |  |
| API Gateway | `api gateway` |  |
| Internal Application Load Balancer | `alb` |  |
| ECS Cluster | `ecs` |  |
| ECS Fargate Microservices | `fargate` |  |
| ECR Container Registry | `ecr` |  |
| AWS Cloud Map | `cloud map` |  |
| Aurora PostgreSQL Cluster | `aurora` |  |
| Aurora Primary AZ-A | `rds` |  |
| Aurora Replica AZ-B | `rds` |  |
| Aurora Replica AZ-C | `rds` |  |
| ElastiCache Redis Cluster | `elasticache` |  |
| Redis Primary AZ-A | `elasticache` |  |
| Redis Replica AZ-B | `elasticache` |  |
| Redis Replica AZ-C | `elasticache` |  |
| Secrets Manager | `secrets manager` |  |
| Application KMS Key | `kms` |  |
| CloudWatch Logs KMS Key | `kms` |  |
| ALB Logs S3 KMS Key | `kms` |  |
| CloudWatch Logs | `cloudwatch` |  |
| CloudWatch Dashboard | `cloudwatch` |  |
| S3 ALB Access Logs | `s3` |  |

## Cost Breakdown

| Service | Monthly Cost |
|---|---|
| nat gateway | $32.85 |
| nat gateway | $32.85 |
| nat gateway | $32.85 |
| waf | $5.00 |
| api gateway | $35.00 |
| alb | $16.43 |
| ecs | $9.01 |
| fargate | $36.04 |
| ecr | $5.00 |
| aurora | $189.80 |
| elasticache | $12.41 |
| elasticache | $150.38 |
| elasticache | $150.38 |
| elasticache | $150.38 |
| secrets manager | $1.00 |
| kms | $1.00 |
| kms | $1.00 |
| kms | $1.00 |

## Security

Shield scan: **✅ PASSED**
- Critical: 0 | High: 2 | Medium: 36 | Low: 15

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
| [NAT Gateway AZ-A](docs/runbooks/RUNBOOK-OPS-001-nat-gateway-az-a.md) | Operational Runbook |
| [NAT Gateway AZ-B](docs/runbooks/RUNBOOK-OPS-002-nat-gateway-az-b.md) | Operational Runbook |
| [NAT Gateway AZ-C](docs/runbooks/RUNBOOK-OPS-003-nat-gateway-az-c.md) | Operational Runbook |

---
*Generated by [CloudCrew AI](https://cloudcrewai.com) — Session `2a070023-0db0-4387-aa22-a5ac6218424e`*