# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-01

## Context
Ensuring the infrastructure operates within budget while meeting performance and availability requirements is a key consideration. This ADR summarizes the cost-related decisions made during the architecture design.

## Decision
The architecture prioritizes managed services like ECS Fargate and RDS PostgreSQL for their operational benefits, which contribute to the overall cost of $800.53/month. While specific instance type choices for compute and database are not detailed here, the selection of Fargate implies a preference for a pay-per-use model over provisioned capacity. Cost optimisation efforts would focus on rightsizing and leveraging Graviton instances where applicable in future iterations.

## Consequences
- **Positive**: Operational efficiency gained by using managed services.
- **Positive**: Predictable costs associated with Fargate's compute model.
- **Negative**: Potential for higher costs compared to self-managed, highly optimized infrastructure.
- **Negative**: Further optimisation may be required post-launch to fine-tune costs.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
The total estimated cost for this deployment is $800.53/month.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.