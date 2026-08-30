# Highly Available ECS Fargate Microservices

Highly available ECS Fargate microservices platform across two AZs with a three-tier VPC, ALB, RDS PostgreSQL, ElastiCache Redis, and comprehensive security and observability.

![CloudCrew AI](https://img.shields.io/badge/Generated%20By-CloudCrew%20AI-02C39A)
![IaC Engine](https://img.shields.io/badge/IaC-Terraform%20%2B%20Pulumi-blue)
![Region](https://img.shields.io/badge/Region-us-east-1-orange)

## Architecture

📐 [View Architecture Diagram](https://github.com/cloudcrewai/cloudcrew-deployments/blob/cloudcrew-169b9203/docs/architecture.png)

## Overview

| Property | Value |
|---|---|
| Project | `ecs-microservices` |
| Environment | `prod` |
| Region | `us-east-1` |
| IaC Engine | Terraform + Pulumi |
| Availability Zones | 2 |
| Estimated Monthly Cost | $800.53 |
| Session ID | `169b9203-4b36-4030-be66-977ecc4083cc` |

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
| Database Subnet AZ-A | `private subnet` |  |
| Database Subnet AZ-B | `private subnet` |  |
| Application Load Balancer | `alb` |  |
| ECS Fargate Microservices | `ecs` |  |
| Aurora PostgreSQL Primary | `aurora` |  |
| Aurora PostgreSQL Standby | `aurora` |  |
| Redis Primary | `elasticache` |  |
| Redis Replica | `elasticache` |  |
| S3 ALB Access Logs | `s3` |  |
| KMS Key for S3 ALB Logs | `kms` |  |
| CloudWatch Logs | `cloudwatch` |  |
| KMS Key for CloudWatch Logs | `kms` |  |

## Cost Breakdown

| Service | Monthly Cost |
|---|---|
| nat gateway | $32.85 |
| nat gateway | $32.85 |
| alb | $16.43 |
| ecs | $36.04 |
| aurora | $189.80 |
| aurora | $189.80 |
| elasticache | $150.38 |
| elasticache | $150.38 |
| kms | $1.00 |
| kms | $1.00 |
| **Total** | **$800.53** |

## Security

Shield scan: **✅ PASSED**
- Critical: 0 | High: 1 | Medium: 28 | Low: 9

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
| [Security Posture Evaluation](docs/adr/ADR-004-security-posture-evaluation.md) | Architecture Decision Record |
| [Cost Optimisation Strategy](docs/adr/ADR-005-cost-optimisation-strategy.md) | Architecture Decision Record |
| [App VPC](docs/runbooks/RUNBOOK-OPS-001-app-vpc.md) | Operational Runbook |
| [Internet Gateway](docs/runbooks/RUNBOOK-OPS-002-internet-gateway.md) | Operational Runbook |
| [NAT Gateway AZ-A](docs/runbooks/RUNBOOK-OPS-003-nat-gateway-az-a.md) | Operational Runbook |
| [NAT Gateway AZ-B](docs/runbooks/RUNBOOK-OPS-004-nat-gateway-az-b.md) | Operational Runbook |
| [Public Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-005-public-subnet-az-a.md) | Operational Runbook |
| [Public Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-006-public-subnet-az-b.md) | Operational Runbook |
| [Private Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-007-private-subnet-az-a.md) | Operational Runbook |
| [Private Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-008-private-subnet-az-b.md) | Operational Runbook |

---
*Generated by [CloudCrew AI](https://cloudcrewai.com) — Session `169b9203-4b36-4030-be66-977ecc4083cc`*