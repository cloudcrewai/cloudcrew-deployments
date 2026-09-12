# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-12

## Context
While detailed cost optimization is an ongoing process, the initial infrastructure blueprint was reviewed for cost-conscious design choices that balance performance and affordability for a production environment.

## Decision
The selection of ECS Fargate and Aurora PostgreSQL, while offering managed benefits, represents a trade-off between operational simplicity and direct cost control. Decisions regarding instance sizing and storage were made with performance requirements in mind, and further right-sizing opportunities will be evaluated based on actual usage patterns.

## Consequences
- **Positive**: Leverages managed services, potentially reducing operational costs associated with infrastructure maintenance.
- **Positive**: Initial configuration aims for appropriate performance levels, avoiding over-provisioning for critical services.
- **Negative**: Serverless compute (Fargate) and managed databases (Aurora) can incur higher baseline costs compared to self-managed alternatives.
- **Negative**: Ongoing monitoring and potential re-evaluation of resource configurations are necessary to realize further cost efficiencies.

## Agents Involved
Prism, Scribe

## Cost Impact
Prism cost estimate indicates 'Total: not estimated'. Specific cost drivers include Fargate task usage, Aurora instance class, storage, and I/O. Ongoing monitoring by Prism is recommended.

## Security Findings
N/A