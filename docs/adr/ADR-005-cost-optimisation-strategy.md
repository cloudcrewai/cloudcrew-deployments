# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-08-30

## Context
The project aims to deploy a cost-effective solution while meeting performance and availability requirements. Key decisions regarding instance types, service configurations, and resource provisioning impact the overall cost.

## Decision
The primary cost driver is the use of ECS Fargate for compute, which offers a serverless operational model. While potentially more expensive than EC2 for constant high utilization, it reduces management overhead. The selection of RDS and ElastiCache services, along with NAT Gateways for outbound connectivity, also contributes to the overall cost. Specific instance types and configurations were chosen based on the balance between performance needs and cost as reflected in the total estimate.

## Consequences
- **Positive**: Reduced operational costs associated with server management.
- **Positive**: Pay-as-you-go model for Fargate can be cost-effective for variable workloads.
- **Negative**: Fargate compute can be more expensive than provisioned EC2 for sustained high resource utilization.
- **Negative**: Managed services like RDS and ElastiCache have inherent costs.

## Agents Involved
Prism, Scribe

## Cost Impact
The total estimated cost for this deployment is $800.53/month.

## Security Findings
N/A