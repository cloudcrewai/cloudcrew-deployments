# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-15

## Context
The application requires containerized workloads to host the web and application tiers. The decision needs to balance operational overhead, scalability, and cost-effectiveness for a production environment.

## Decision
ECS Fargate was selected for the container compute platform. This choice eliminates the need for managing underlying EC2 instances, simplifying operations and allowing the team to focus on application deployment and scaling. Fargate also provides a robust, serverless compute environment suitable for production workloads.

## Consequences
- **Positive**: Reduced operational overhead due to serverless compute.
- **Positive**: Seamless integration with other AWS services.
- **Negative**: Potential for slightly higher per-request costs compared to EC2 instances under heavy, consistent load.
- **Negative**: Less control over the underlying compute environment.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
Cost depends on Fargate task usage, not estimated.

## Security Findings
N/A