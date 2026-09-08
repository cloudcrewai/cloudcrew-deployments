# ADR-004: Cost Optimisation for Aurora PostgreSQL Cluster

## Status
Accepted

## Date
2026-09-08

## Context
While the primary focus is on production readiness and availability, cost considerations are important for sustainable operations. The selection of database instances and features impacts the overall cost.

## Decision
The decision to use Aurora PostgreSQL implies leveraging AWS's managed service, which bundles infrastructure, patching, and high availability. Specific instance class and storage sizing are not detailed in the blueprint, leaving room for optimisation. The `deletion_protection` and `backup_retention_period` (14 days) are set for operational safety and recovery, which may have cost implications.

## Consequences
- **Positive**: Reduced operational overhead compared to self-managed databases can lead to indirect cost savings.
- **Negative**: Aurora instances and features can be more expensive than equivalent self-managed solutions. Specific instance types and storage tiers not detailed in the blueprint prevent granular cost analysis in this ADR.

## Agents Involved
Atlas, Prism, Scribe

## Cost Impact
Total cost is not estimated.

## Security Findings
Security findings not applicable to this ADR.