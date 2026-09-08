# Production VPC with RDS

Production-grade VPC in us-east-1 across 3 AZs with public, private, and database subnets, NAT gateways, VPC endpoints, flow logs, and a Multi-AZ RDS PostgreSQL instance.

![CloudCrew AI](https://img.shields.io/badge/Generated%20By-CloudCrew%20AI-02C39A)
![IaC Engine](https://img.shields.io/badge/IaC-Terraform%20%2B%20Pulumi-blue)
![Region](https://img.shields.io/badge/Region-us-east-1-orange)

## Architecture

📐 [View Architecture Diagram](https://github.com/cloudcrewai/cloudcrew-deployments/blob/cloudcrew-385cd98e/docs/architecture.png)

## Overview

| Property | Value |
|---|---|
| Project | `production-vpc-rds` |
| Environment | `prod` |
| Region | `us-east-1` |
| IaC Engine | Terraform + Pulumi |
| Availability Zones | 3 |
| Estimated Monthly Cost | $419.10 |
| Session ID | `385cd98e-eb93-489d-b512-644cb72fec81` |

## Components

| Component | Type | Description |
|---|---|---|
| App VPC | `vpc` |  |
| Internet Gateway | `internet gateway` |  |
| Public Subnet AZ-A | `public subnet` |  |
| Public Subnet AZ-B | `public subnet` |  |
| Public Subnet AZ-C | `public subnet` |  |
| Private Subnet AZ-A | `private subnet` |  |
| Private Subnet AZ-B | `private subnet` |  |
| Private Subnet AZ-C | `private subnet` |  |
| Database Subnet AZ-A | `database subnet` |  |
| Database Subnet AZ-B | `database subnet` |  |
| Database Subnet AZ-C | `database subnet` |  |
| NAT Gateway AZ-A | `nat gateway` |  |
| NAT Gateway AZ-B | `nat gateway` |  |
| NAT Gateway AZ-C | `nat gateway` |  |
| RDS PostgreSQL Primary | `rds` |  |
| RDS PostgreSQL Standby AZ-B | `rds` |  |
| RDS PostgreSQL Standby AZ-C | `rds` |  |
| S3 VPC Endpoint | `vpc_endpoint` |  |
| ECR API VPC Endpoint | `vpc_endpoint` |  |
| ECR DKR VPC Endpoint | `vpc_endpoint` |  |
| Secrets Manager VPC Endpoint | `vpc_endpoint` |  |
| KMS VPC Endpoint | `vpc_endpoint` |  |
| CloudWatch Logs VPC Endpoint | `vpc_endpoint` |  |
| VPC Flow Logs Log Group | `cloudwatch_log_group` |  |
| VPC Flow Logs | `vpc_flow_logs` |  |
| KMS Key for CloudWatch Logs | `kms` |  |
| KMS Alias for CloudWatch Logs | `kms_alias` |  |
| CloudWatch | `cloudwatch` |  |
| CloudTrail | `cloudtrail` |  |

## Cost Breakdown

| Service | Monthly Cost |
|---|---|
| nat gateway | $32.85 |
| nat gateway | $32.85 |
| nat gateway | $32.85 |
| rds | $105.85 |
| rds | $105.85 |
| rds | $105.85 |
| kms | $1.00 |
| kms_alias | $2.00 |
| **Total** | **$419.10** |

## Security

Shield scan: **✅ PASSED**
- Critical: 0 | High: 0 | Medium: 25 | Low: 5

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
| [Database Engine Selection](docs/adr/ADR-001-database-engine-selection.md) | Architecture Decision Record |
| [Network Topology Design](docs/adr/ADR-002-network-topology-design.md) | Architecture Decision Record |
| [Security Posture Summary](docs/adr/ADR-003-security-posture-summary.md) | Architecture Decision Record |
| [Cost Optimisation Strategy](docs/adr/ADR-004-cost-optimisation-strategy.md) | Architecture Decision Record |
| [App VPC](docs/runbooks/RUNBOOK-OPS-001-app-vpc.md) | Operational Runbook |
| [Internet Gateway](docs/runbooks/RUNBOOK-OPS-002-internet-gateway.md) | Operational Runbook |
| [Public Subnet AZ-A, AZ-B, AZ-C](docs/runbooks/RUNBOOK-OPS-003-public-subnet-az-a-az-b-az-c.md) | Operational Runbook |
| [Private Subnet AZ-A, AZ-B, AZ-C](docs/runbooks/RUNBOOK-OPS-004-private-subnet-az-a-az-b-az-c.md) | Operational Runbook |
| [Database Subnet AZ-A, AZ-B, AZ-C](docs/runbooks/RUNBOOK-OPS-005-database-subnet-az-a-az-b-az-c.md) | Operational Runbook |

---
*Generated by [CloudCrew AI](https://cloudcrewai.com) — Session `385cd98e-eb93-489d-b512-644cb72fec81`*