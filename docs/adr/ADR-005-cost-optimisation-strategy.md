# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-15

## Context
For a production environment, balancing cost-effectiveness with performance and availability is essential. Decisions regarding instance types, resource sizing, and service choices directly impact the overall operational expenditure.

## Decision
The current configuration utilizes ECS Fargate for compute, RDS PostgreSQL for the database, and ElastiCache Redis. While specific instance types and sizing details are not provided in this excerpt, the overall cost estimate of $1091.93/month suggests a balance has been struck. The use of managed services like RDS and ElastiCache implies acceptance of their associated costs in exchange for reduced operational overhead and built-in high availability features.

## Consequences
- **Positive**: Reduced operational burden through managed services.
- **Positive**: Built-in high availability features reduce the need for manual failover configurations.
- **Negative**: Managed services may incur higher direct costs compared to self-managed alternatives.
- **Negative**: Without specific right-sizing details, there's a potential for over-provisioning and unnecessary costs.

## Agents Involved
Prism, Scribe

## Cost Impact
The total estimated monthly cost is $1091.93.

## Security Findings
N/A for cost optimisation ADR.