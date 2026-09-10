# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-10

## Context
The infrastructure deployment aims to balance performance, availability, and cost for a production environment. Specific choices were made regarding resource types and configurations to achieve this balance.

## Decision
The architecture utilizes ECS Fargate for compute, abstracting away instance management and aligning costs with actual usage. While specific cost optimisation recommendations are not detailed in the provided blueprint, the selection of managed services like RDS and ElastiCache implies a trade-off favoring operational simplicity and availability over potentially lower, self-managed costs. The total estimated cost is $1089.93/month.

## Consequences
- **Positive**: Operational efficiency gained by leveraging managed services.
- **Positive**: Pay-as-you-go model for Fargate can be cost-effective for variable workloads.
- **Negative**: Managed services can sometimes be more expensive than self-hosted alternatives for consistent, high-utilization loads.
- **Negative**: Less direct control over underlying resource costs.

## Agents Involved
Prism, Scribe

## Cost Impact
Total estimated cost for the environment is $1089.93/month.

## Security Findings
N/A for this ADR.