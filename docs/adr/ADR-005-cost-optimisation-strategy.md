# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-07

## Context
The architecture was designed with cost-effectiveness in mind, balancing performance and scalability requirements with budget considerations for a production environment.

## Decision
The current configuration utilizes ECS Fargate and RDS PostgreSQL, which are managed services offering a balance of capability and operational ease. While specific optimisation strategies like Graviton instance types or right-sizing are not explicitly detailed in the blueprint, the chosen services provide inherent scalability that can help manage costs by scaling resources based on demand.

## Consequences
- **Positive**: Managed services reduce the need for manual cost management of underlying infrastructure.
- **Positive**: Automatic scaling capabilities can help align costs with actual usage.
- **Negative**: Without explicit right-sizing or specific instance type choices (e.g., Graviton), there may be opportunities for further cost savings.
- **Negative**: Managed services can sometimes have a higher baseline cost than self-managed alternatives.

## Agents Involved
Prism, Scribe

## Cost Impact
The total estimated cost is $231.29/month, reflecting the chosen services and their configurations.

## Security Findings
N/A