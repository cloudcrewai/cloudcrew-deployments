# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-14

## Context
The architecture needs to balance performance, availability, and cost-effectiveness for a production environment. Key decisions involve selecting appropriate instance types and service configurations.

## Decision
The current configuration utilizes ECS Fargate for compute, RDS PostgreSQL for the database, and ElastiCache for caching. While specific instance types and sizes are not detailed in the blueprint, the selection of managed services like Fargate and RDS aims to reduce operational costs by offloading management overhead. The total estimated cost is $1081.93/month.

## Consequences
- **Positive**: Leverages managed services to reduce operational expenditure.
- **Positive**: Production-grade services selected for reliability.
- **Negative**: Managed services may incur higher direct costs compared to self-managed alternatives for equivalent resources.
- **Negative**: Without specific right-sizing details, potential for over-provisioning exists, impacting cost-efficiency.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
The total estimated monthly cost for this deployment is $1081.93.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.