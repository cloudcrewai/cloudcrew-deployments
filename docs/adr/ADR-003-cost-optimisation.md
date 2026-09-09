# ADR-003: Cost Optimisation

## Status
Accepted

## Date
2026-09-09

## Context
The ML platform is a production workload, requiring a balance between performance, availability, and cost-effectiveness. Resource provisioning and network access patterns were evaluated to identify opportunities for cost optimization without compromising operational requirements.

## Decision
The architecture utilizes private subnets and VPC endpoints to reduce data transfer costs compared to routing traffic over the internet. While specific instance types for compute are not detailed in this blueprint excerpt, the general principle is to leverage AWS managed services and private connectivity where possible. The overall estimated cost is $67.70/month, reflecting a baseline operational cost.

## Consequences
- **Positive**: Reduced data transfer costs by utilizing VPC endpoints.
- **Positive**: Controlled baseline operational costs through strategic service selection.
- **Negative**: Potential for underutilization of resources if not actively managed and right-sized.
- **Negative**: Reliance on managed services may limit deep cost-cutting opportunities available with self-managed solutions.

## Agents Involved
Atlas, Prism, Scribe

## Cost Impact
Total estimated cost is $67.70/month.

## Security Findings
N/A