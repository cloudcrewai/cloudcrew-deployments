# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-15

## Context
To ensure cost-effectiveness for the production three-tier web application, specific instance types and configurations were evaluated. The goal is to balance performance requirements with budgetary constraints.

## Decision
The deployment utilizes standard compute and database instance types suitable for production workloads. While specific optimizations like Graviton instances or aggressive right-sizing were not explicitly detailed in the blueprint, the chosen architecture aims for a balance between performance and cost. The total estimated monthly cost is $1091.93.

## Consequences
- **Positive**: Predictable performance for production workloads.
- **Positive**: Utilizes generally available and well-supported instance types.
- **Negative**: Potential for cost savings could be realised through further optimisation of instance types and storage.
- **Negative**: Performance trade-offs for cost savings were not explicitly prioritised in this configuration.

## Agents Involved
Prism, Scribe

## Cost Impact
The estimated total monthly cost for this deployment is $1091.93.

## Security Findings
N/A