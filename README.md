# Production Three-Tier Web App

Highly available three-tier web application with CloudFront, WAF, ALB, ECS Fargate, RDS PostgreSQL Multi-AZ, ElastiCache Redis Multi-AZ, and comprehensive security and observability across two Availability Zones.

![CloudCrew AI](https://img.shields.io/badge/Generated%20By-CloudCrew%20AI-02C39A)
![IaC Engine](https://img.shields.io/badge/IaC-Terraform%20%2B%20Pulumi-blue)
![Region](https://img.shields.io/badge/Region-us-east-1-orange)

## Architecture

📐 [View Architecture Diagram](https://github.com/cloudcrewai/cloudcrew-deployments/blob/cloudcrew-cdd6099f/docs/architecture.png)

## Overview

| Property | Value |
|---|---|
| Project | `production-three-tie` |
| Environment | `production` |
| Region | `us-east-1` |
| IaC Engine | Terraform + Pulumi |
| Availability Zones | 2 |
| Estimated Monthly Cost | $1,160.22 |
| Session ID | `cdd6099f-63e9-4013-b77f-9bdb8aef4b62` |

## Components

| Component | Type | Description |
|---|---|---|
| App VPC | `vpc` |  |
| Internet Gateway | `internet gateway` |  |
| NAT Gateway AZ-A | `nat gateway` |  |
| NAT Gateway AZ-B | `nat gateway` |  |
| Public Subnet AZ-A | `public subnet` |  |
| Public Subnet AZ-B | `public subnet` |  |
| Private App Subnet AZ-A | `private subnet` |  |
| Private App Subnet AZ-B | `private subnet` |  |
| Private Data Subnet AZ-A | `private subnet` |  |
| Private Data Subnet AZ-B | `private subnet` |  |
| Route53 Hosted Zone | `route53` |  |
| ACM Certificate | `acm` |  |
| CloudFront Distribution | `cloudfront` |  |
| WAF Web ACL (CloudFront) | `waf` |  |
| Application Load Balancer | `alb` |  |
| WAF Web ACL (Regional) | `waf` |  |
| ECS Fargate Service | `ecs` |  |
| ECR Repository | `ecr` |  |
| RDS PostgreSQL Primary | `rds` |  |
| RDS PostgreSQL Standby | `rds` |  |
| RDS Proxy | `rds` |  |
| Redis Primary | `elasticache` |  |
| Redis Replica | `elasticache` |  |
| RDS Master Credentials | `secrets manager` |  |
| Redis Auth Token | `secrets manager` |  |
| KMS Key for RDS | `kms` |  |
| KMS Key for ElastiCache | `kms` |  |
| KMS Key for CloudWatch Logs | `kms` |  |
| KMS Key for ALB Logs | `kms` |  |
| KMS Key for Flow Logs | `kms` |  |
| KMS Key for CloudTrail Logs | `kms` |  |
| S3 Bucket for ALB Logs | `s3` |  |
| S3 Bucket for VPC Flow Logs | `s3` |  |
| S3 Bucket for CloudTrail Logs | `s3` |  |
| S3 Bucket for App Assets | `s3` |  |
| DynamoDB Table (Placeholder) | `dynamodb` |  |
| VPC Endpoint (S3 Gateway) | `vpc endpoint` |  |
| VPC Endpoint (DynamoDB Gateway) | `vpc endpoint` |  |
| VPC Endpoint (ECR API) | `vpc endpoint` |  |
| VPC Endpoint (ECR Docker) | `vpc endpoint` |  |
| VPC Endpoint (CloudWatch Logs) | `vpc endpoint` |  |
| VPC Endpoint (Secrets Manager) | `vpc endpoint` |  |
| VPC Endpoint (KMS) | `vpc endpoint` |  |
| VPC Endpoint (SSM) | `vpc endpoint` |  |
| VPC Flow Logs | `cloudwatch` |  |
| EC2 for SSM Debugging | `ec2` |  |
| AWS Config | `cloudwatch` |  |
| Security Hub | `cloudwatch` |  |
| GuardDuty | `guardduty` |  |
| SNS Topic for GuardDuty Alerts | `sns` |  |
| EventBridge Rule (GuardDuty) | `eventbridge` |  |
| CloudTrail | `cloudtrail` |  |
| CloudWatch Logs (CloudTrail) | `cloudwatch` |  |
| CloudWatch Logs (ECS) | `cloudwatch` |  |
| CloudWatch Alarms | `cloudwatch` |  |
| CloudWatch Dashboard | `cloudwatch` |  |
| AWS Backup | `cloudwatch` |  |
| Cost Anomaly Detection | `cloudwatch` |  |

## Cost Breakdown

| Service | Monthly Cost |
|---|---|
| nat gateway | $32.85 |
| nat gateway | $32.85 |
| cloudfront | $2.00 |
| waf | $5.00 |
| alb | $16.43 |
| waf | $5.00 |
| ecs | $36.04 |
| ecr | $5.00 |
| rds | $328.50 |
| rds | $328.50 |
| rds | $52.56 |
| elasticache | $150.38 |
| elasticache | $150.38 |
| secrets manager | $1.00 |
| secrets manager | $1.00 |
| kms | $1.00 |
| kms | $1.00 |
| kms | $1.00 |
| kms | $1.00 |
| kms | $1.00 |
| kms | $1.00 |
| ec2 | $6.13 |
| sns | $0.50 |
| eventbridge | $0.10 |
| **Total** | **$1,160.22** |

## Security

Shield scan: **✅ PASSED**
- Critical: 0 | High: 3 | Medium: 44 | Low: 16

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
| [Cost Optimization Strategy](docs/adr/ADR-005-cost-optimization-strategy.md) | Architecture Decision Record |
| [App VPC](docs/runbooks/RUNBOOK-OPS-001-app-vpc.md) | Operational Runbook |
| [NAT Gateway AZ-A](docs/runbooks/RUNBOOK-OPS-002-nat-gateway-az-a.md) | Operational Runbook |
| [NAT Gateway AZ-B](docs/runbooks/RUNBOOK-OPS-003-nat-gateway-az-b.md) | Operational Runbook |
| [Public Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-004-public-subnet-az-a.md) | Operational Runbook |
| [Public Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-005-public-subnet-az-b.md) | Operational Runbook |
| [Private App Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-006-private-app-subnet-az-a.md) | Operational Runbook |
| [Private App Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-007-private-app-subnet-az-b.md) | Operational Runbook |
| [Private Data Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-008-private-data-subnet-az-a.md) | Operational Runbook |

---
*Generated by [CloudCrew AI](https://cloudcrewai.com) — Session `cdd6099f-63e9-4013-b77f-9bdb8aef4b62`*