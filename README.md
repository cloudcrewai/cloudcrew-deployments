# Production Data Platform

Highly available data platform across 2 AZs with Aurora PostgreSQL, RDS MySQL, ElastiCache Redis, and dedicated KMS/Secrets Manager for each.

![CloudCrew AI](https://img.shields.io/badge/Generated%20By-CloudCrew%20AI-02C39A)
![IaC Engine](https://img.shields.io/badge/IaC-Terraform%20%2B%20Pulumi-blue)
![Region](https://img.shields.io/badge/Region-us-east-1-orange)

## Architecture

📐 [View Architecture Diagram](https://github.com/cloudcrewai/cloudcrew-deployments/blob/cloudcrew-73837efc/docs/architecture.png)

## Overview

| Property | Value |
|---|---|
| Project | `data-platform` |
| Environment | `production` |
| Region | `us-east-1` |
| IaC Engine | Terraform + Pulumi |
| Availability Zones | 2 |
| Estimated Monthly Cost | $1,518.83 |
| Session ID | `73837efc-743e-4cf3-a2ad-61a7e609f5f0` |

## Components

| Component | Type | Description |
|---|---|---|
| Data Platform VPC | `vpc` |  |
| Internet Gateway | `internet gateway` |  |
| NAT Gateway AZ-A | `nat gateway` |  |
| NAT Gateway AZ-B | `nat gateway` |  |
| Public Subnet AZ-A | `public subnet` |  |
| Public Subnet AZ-B | `public subnet` |  |
| Private Subnet AZ-A | `private subnet` |  |
| Private Subnet AZ-B | `private subnet` |  |
| Database Subnet AZ-A | `private subnet` |  |
| Database Subnet AZ-B | `private subnet` |  |
| KMS Key for Aurora | `kms` |  |
| Aurora DB Credentials | `secrets manager` |  |
| Aurora PostgreSQL Cluster | `aurora` |  |
| Aurora Instance AZ-A | `aurora` |  |
| Aurora Instance AZ-B | `aurora` |  |
| Aurora PostgreSQL Parameter Group | `rds` |  |
| KMS Key for RDS MySQL | `kms` |  |
| RDS MySQL Credentials | `secrets manager` |  |
| RDS MySQL Primary | `rds` |  |
| RDS MySQL Standby | `rds` |  |
| RDS MySQL Parameter Group | `rds` |  |
| KMS Key for ElastiCache | `kms` |  |
| ElastiCache Auth Token | `secrets manager` |  |
| ElastiCache Redis Primary | `elasticache` |  |
| ElastiCache Redis Replica | `elasticache` |  |
| KMS Key for CloudWatch Logs | `kms` |  |
| Aurora Logs | `cloudwatch` |  |
| RDS MySQL Logs | `cloudwatch` |  |
| ElastiCache Logs | `cloudwatch` |  |
| CloudTrail Logs | `cloudwatch` |  |
| CloudTrail Log Bucket | `s3` |  |
| CloudTrail | `cloudtrail` |  |

## Cost Breakdown

| Service | Monthly Cost |
|---|---|
| nat gateway | $32.85 |
| nat gateway | $32.85 |
| kms | $1.00 |
| secrets manager | $1.00 |
| aurora | $189.80 |
| aurora | $189.80 |
| aurora | $189.80 |
| rds | $52.56 |
| kms | $1.00 |
| secrets manager | $1.00 |
| rds | $313.90 |
| rds | $156.95 |
| rds | $52.56 |
| kms | $1.00 |
| secrets manager | $1.00 |
| elasticache | $150.38 |
| elasticache | $150.38 |
| kms | $1.00 |
| **Total** | **$1,518.83** |

## Security

Shield scan: **✅ PASSED**
- Critical: 0 | High: 5 | Medium: 34 | Low: 9

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
| [Primary Database Engine Selection](docs/adr/ADR-001-primary-database-engine-selection.md) | Architecture Decision Record |
| [Network Topology Design](docs/adr/ADR-002-network-topology-design.md) | Architecture Decision Record |
| [Security Posture Assessment](docs/adr/ADR-003-security-posture-assessment.md) | Architecture Decision Record |
| [Cost Optimisation Strategy](docs/adr/ADR-004-cost-optimisation-strategy.md) | Architecture Decision Record |
| [Data Platform VPC](docs/runbooks/RUNBOOK-OPS-001-data-platform-vpc.md) | Operational Runbook |
| [NAT Gateway AZ-A](docs/runbooks/RUNBOOK-OPS-002-nat-gateway-az-a.md) | Operational Runbook |
| [NAT Gateway AZ-B](docs/runbooks/RUNBOOK-OPS-003-nat-gateway-az-b.md) | Operational Runbook |
| [Public Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-004-public-subnet-az-a.md) | Operational Runbook |
| [Public Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-005-public-subnet-az-b.md) | Operational Runbook |
| [Private Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-006-private-subnet-az-a.md) | Operational Runbook |
| [Private Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-007-private-subnet-az-b.md) | Operational Runbook |
| [Database Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-008-database-subnet-az-a.md) | Operational Runbook |

---
*Generated by [CloudCrew AI](https://cloudcrewai.com) — Session `73837efc-743e-4cf3-a2ad-61a7e609f5f0`*