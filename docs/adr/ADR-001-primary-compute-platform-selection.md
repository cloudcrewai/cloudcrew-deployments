# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-19

## Context
The application requires containerised workloads for its web and API tiers. The choice between ECS Fargate, ECS EC2, and Lambda needs to balance operational overhead, scalability, and cost.

## Decision
ECS Fargate was selected for the application's container compute platform. This choice eliminates the need for managing underlying EC2 instances, providing a serverless operational model for containers. Fargate offers automatic scaling and patching of the underlying infrastructure, simplifying management and allowing the team to focus on application deployment.

## Consequences
- **Positive**: Reduced operational burden due to no EC2 instance management.
- **Positive**: Seamless integration with AWS security and networking services.
- **Negative**: Potentially higher cost per vCPU/memory compared to self-managed EC2 instances.
- **Negative**: Less control over the underlying execution environment.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
The selected compute platform contributes to the estimated total monthly cost of $1157.60, with specific Fargate costs determined by usage patterns.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.