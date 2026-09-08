# ADR-004: Cost Optimisation

## Status
Accepted

## Date
2026-09-08

## Context
The deployment's cost-effectiveness was assessed, focusing on resource sizing and selection to balance performance and expenditure. The goal is to ensure that the chosen services align with budget constraints for a production environment.

## Decision
The primary cost consideration is the use of Aurora Serverless v2 for PostgreSQL. While offering automatic scaling, its cost structure is based on actual usage, which can be more economical for variable workloads compared to provisioned instances. The total estimated cost for the database component is $257.50 per month.

## Consequences
- **Positive**: Pay-per-use model can be cost-effective for fluctuating demand.
- **Positive**: Eliminates the need to over-provision resources for peak loads.
- **Negative**: For consistently high workloads, provisioned instances might offer a lower cost per unit of performance.
- **Negative**: The total cost is dependent on actual usage patterns.

## Agents Involved
Prism, Scribe

## Cost Impact
Total estimated monthly cost: $257.50.

## Security Findings
None