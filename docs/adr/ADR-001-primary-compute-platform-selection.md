# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-10

## Context
The application requires containerised workloads for its web and API tiers. The choice needs to balance operational overhead, scalability, and cost-effectiveness for a production environment.

## Decision
ECS Fargate was selected as the compute platform. This decision was made to eliminate the need for managing underlying EC2 instances, simplifying operations and allowing the focus to remain on application deployment and scaling. Fargate provides a serverless compute engine for containers, abstracting away infrastructure management.

## Consequences
- **Positive**: Reduced operational burden due to no EC2 instance management.
- **Positive**: Automatic scaling based on demand without manual intervention on instance capacity.
- **Negative**: Potential for higher cost compared to optimized EC2 instances for predictable, high-utilization workloads.
- **Negative**: Less control over the underlying compute environment compared to EC2.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
ECS Fargate costs are a significant portion of the total estimated $1089.93/month.

## Security Findings
N/A for this ADR.