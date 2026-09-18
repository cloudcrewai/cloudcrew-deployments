# Production Three-Tier Web App

Highly available three-tier web application across two AZs with CloudFront, WAF, ALB, ECS Fargate, RDS PostgreSQL, and ElastiCache Redis, featuring comprehensive security, monitoring, and backup.

![CloudCrew AI](https://img.shields.io/badge/Generated%20By-CloudCrew%20AI-02C39A)
![IaC Engine](https://img.shields.io/badge/IaC-Terraform%20%2B%20Pulumi-blue)
![Region](https://img.shields.io/badge/Region-us-east-1-orange)

## Architecture

📐 [View Architecture Diagram](https://github.com/cloudcrewai/cloudcrew-deployments/blob/cloudcrew-85a804b9/docs/architecture.png)

## Overview

| Property | Value |
|---|---|
| Project | `production-three-tie` |
| Environment | `production` |
| Region | `us-east-1` |
| IaC Engine | Terraform + Pulumi |
| Availability Zones | 2 |
| Estimated Monthly Cost | $1,157.60 |
| Session ID | `85a804b9-d209-42da-a226-6697eed38242` |

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
| ALB Access Logs S3 | `s3` |  |
| KMS Key for ALB Logs | `kms` |  |
| ECS Cluster | `ecs` |  |
| ECS Fargate Service | `fargate` |  |
| ECR Repository | `ecr` |  |
| KMS Key for RDS | `kms` |  |
| RDS PostgreSQL Primary | `rds` |  |
| RDS PostgreSQL Standby | `rds` |  |
| RDS Proxy | `rds` |  |
| KMS Key for ElastiCache | `kms` |  |
| ElastiCache Redis Primary | `elasticache` |  |
| ElastiCache Redis Replica | `elasticache` |  |
| RDS Master Credentials | `secrets manager` |  |
| Redis AUTH Token | `secrets manager` |  |
| Secrets Manager VPCE | `vpc endpoint` |  |
| S3 Gateway VPCE | `vpc endpoint` |  |
| DynamoDB Gateway VPCE | `vpc endpoint` |  |
| ECR API VPCE | `vpc endpoint` |  |
| ECR Docker VPCE | `vpc endpoint` |  |
| CloudWatch Logs VPCE | `vpc endpoint` |  |
| KMS VPCE | `vpc endpoint` |  |
| SSM VPCE | `vpc endpoint` |  |
| VPC Flow Logs S3 | `s3` |  |
| CloudTrail S3 | `s3` |  |
| CloudTrail | `cloudtrail` |  |
| KMS Key for CloudWatch Logs | `kms` |  |
| ECS Log Group | `cloudwatch` |  |
| CloudTrail Log Group | `cloudwatch` |  |
| Operational Dashboard | `cloudwatch` |  |
| ALB 5xx Error Alarm | `cloudwatch` |  |
| RDS CPU Utilization Alarm | `cloudwatch` |  |
| ECS Task CPU Utilization Alarm | `cloudwatch` |  |
| ALB Response Time Alarm | `cloudwatch` |  |
| CloudWatch Alarms SNS Topic | `sns` |  |
| GuardDuty Findings SNS Topic | `sns` |  |
| GuardDuty Findings Rule | `eventbridge` |  |
| AWS Config Recorder | `config` |  |
| AWS Config Delivery Channel | `config` |  |
| Security Hub | `security hub` |  |
| GuardDuty Detector | `guardduty` |  |
| RDS Backup Plan | `aws backup` |  |
| App Assets S3 | `s3` |  |

## Cost Breakdown

| Service | Monthly Cost |
|---|---|
| nat gateway | $32.85 |
| nat gateway | $32.85 |
| cloudfront | $2.00 |
| waf | $5.00 |
| alb | $16.43 |
| waf | $5.00 |
| kms | $1.00 |
| ecs | $9.01 |
| fargate | $36.04 |
| ecr | $1.00 |
| kms | $1.00 |
| rds | $328.50 |
| rds | $328.50 |
| rds | $52.56 |
| kms | $1.00 |
| elasticache | $150.38 |
| elasticache | $150.38 |
| secrets manager | $1.00 |
| secrets manager | $1.00 |
| kms | $1.00 |
| sns | $0.50 |
| sns | $0.50 |
| eventbridge | $0.10 |
| **Total** | **$1,157.60** |

## Security

Shield scan: **✅ PASSED**
- Critical: 0 | High: 5 | Medium: 34 | Low: 16

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
| [Cost Optimisation Strategy](docs/adr/ADR-005-cost-optimisation-strategy.md) | Architecture Decision Record |
| [App VPC](docs/runbooks/RUNBOOK-OPS-001-app-vpc.md) | Operational Runbook |
| [Internet Gateway](docs/runbooks/RUNBOOK-OPS-002-internet-gateway.md) | Operational Runbook |
| [NAT Gateway AZ-A](docs/runbooks/RUNBOOK-OPS-003-nat-gateway-az-a.md) | Operational Runbook |
| [NAT Gateway AZ-B](docs/runbooks/RUNBOOK-OPS-004-nat-gateway-az-b.md) | Operational Runbook |
| [Public Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-005-public-subnet-az-a.md) | Operational Runbook |
| [Public Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-006-public-subnet-az-b.md) | Operational Runbook |
| [Private App Subnet AZ-A](docs/runbooks/RUNBOOK-OPS-007-private-app-subnet-az-a.md) | Operational Runbook |
| [Private App Subnet AZ-B](docs/runbooks/RUNBOOK-OPS-008-private-app-subnet-az-b.md) | Operational Runbook |

---
*Generated by [CloudCrew AI](https://cloudcrewai.com) — Session `85a804b9-d209-42da-a226-6697eed38242`*