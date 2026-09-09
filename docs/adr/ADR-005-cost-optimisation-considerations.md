# ADR-005: Cost Optimisation Considerations

## Status
Accepted

## Date
2026-09-09

## Context
The architecture aims to balance performance, availability, and cost-effectiveness for the production environment. Key decisions impacting cost include the choice of compute platform, database service, and other managed services.

## Decision
The architecture employs ECS Fargate for compute, RDS PostgreSQL for the database, and ElastiCache Redis for caching. While specific instance types and configurations are not detailed here, the selection of managed services like RDS and ElastiCache offloads operational costs associated with self-management. The overall cost estimate of $1085.93/month reflects the combination of these services deployed in a production environment across multiple Availability Zones to ensure high availability.

## Consequences
- **Positive**: High availability and resilience are built into the architecture, justifying the cost for a production environment.
- **Positive**: Managed services reduce the burden on the operational team, indirectly saving costs.
- **Negative**: The cost of managed services, particularly for high availability configurations (e.g., Multi-AZ RDS), can be higher than equivalent self-managed solutions.
- **Negative**: Further cost optimisation may be possible through right-sizing instances or exploring Reserved Instances/Savings Plans once usage patterns are established.

## Agents Involved
Prism, Scribe

## Cost Impact
Total estimated monthly cost: $1085.93.

## Security Findings
N/A for this ADR.