# ADR-004: Cost Optimisation

## Status
Accepted

## Date
2026-09-09

## Context
While performance and availability are critical for a production database, cost efficiency remains a consideration. Evaluating instance types, storage, and features helps in making informed decisions to balance cost with operational needs.

## Decision
The cost optimisation strategy focuses on leveraging the Aurora PostgreSQL engine for its performance benefits over provisioned IOPS and right-sizing instances based on anticipated workload. Features like managed backups and multi-AZ reduce the need for additional operational overhead, which indirectly impacts cost.

## Consequences
- **Positive**: Aurora's architecture can be more cost-effective at scale than standard RDS due to performance efficiencies.
- **Positive**: Managed features reduce operational costs associated with database administration.
- **Negative**: Aurora may have a higher baseline cost than self-managed solutions.
- **Negative**: Performance tuning and monitoring are still required to ensure cost-effective operation.

## Agents Involved
Atlas, Prism, Scribe

## Cost Impact
The <cost_estimate> provides a summary of the projected costs. Specific cost drivers include the Aurora instance class, storage consumed, I/O operations, and data transfer.

## Security Findings
No direct security findings impact cost optimisation in this context, but security features like KMS and Secrets Manager have associated costs detailed in <cost_estimate>.