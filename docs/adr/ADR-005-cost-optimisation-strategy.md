# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-18

## Context
The architecture was designed with cost-efficiency in mind, balancing performance, availability, and expenditure. Decisions were made regarding instance types and service configurations to align with the budget.

## Decision
While specific instance types and right-sizing details are not explicitly detailed in the blueprint for this ADR, the overall estimated cost of $1157.60/month reflects the chosen services and configurations. The selection of services like ECS Fargate, RDS, and ElastiCache is assumed to have been made with consideration for their managed benefits and associated costs.

## Consequences
- **Positive**: A defined monthly cost estimate provides budget predictability.
- **Negative**: Without explicit optimisation details, potential for unrecognised cost savings may exist.
- **Negative**: Performance trade-offs for cost savings are not detailed.

## Agents Involved
Prism, Scribe

## Cost Impact
Total estimated cost is $1157.60/month.

## Security Findings
N/A