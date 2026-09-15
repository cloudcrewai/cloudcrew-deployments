# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-15

## Context
While the primary focus is on functionality and availability, cost efficiency is a consideration for a production environment. The selection of services and configurations should reflect a balance between performance, features, and cost.

## Decision
The architecture utilizes managed services like ECS Fargate and RDS, which abstract away much of the underlying infrastructure management cost. Specific instance types and configurations were not detailed in the provided blueprint data for granular optimisation. The current setup focuses on availability and managed operations, with optimisation opportunities potentially lying in right-sizing resources and leveraging reserved instances if applicable.

## Consequences
- **Positive**: Managed services reduce operational overhead, potentially lowering TCO.
- **Positive**: Avoids upfront costs associated with purchasing and managing physical hardware.
- **Negative**: Managed services can sometimes have a higher per-unit cost compared to self-managed alternatives.
- **Negative**: Without specific instance type details, fine-grained cost optimisation (e.g., Graviton, right-sizing) cannot be confirmed.

## Agents Involved
Prism, Scribe

## Cost Impact
Total cost not estimated. Optimisation relies on future analysis of resource utilization.

## Security Findings
N/A