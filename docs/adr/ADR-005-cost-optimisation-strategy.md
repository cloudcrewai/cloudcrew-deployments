# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-19

## Context
Ensuring the application infrastructure is cost-effective without compromising performance or availability is a key consideration. This involves selecting appropriate instance types and resource configurations.

## Decision
The infrastructure's cost is estimated at $1157.60 per month. While the blueprint does not specify specific instance types eligible for Graviton or detailed right-sizing recommendations, the selection of managed services like ECS Fargate and RDS RDS PostgreSQL aims to balance operational efficiency with predictable costs. The focus is on leveraging AWS-managed services to reduce the TCO associated with infrastructure management.

## Consequences
- **Positive**: Managed services reduce operational overhead, potentially lowering indirect costs.
- **Positive**: Predictable cost structure based on service usage.
- **Negative**: Without specific instance type data, potential cost savings from Graviton or right-sizing are not detailed.
- **Negative**: A purely managed service approach might not always be the most cost-optimised for very high-scale or specific workloads.

## Agents Involved
Prism, Scribe

## Cost Impact
The total estimated monthly cost for this infrastructure is $1157.60.

## Security Findings
None