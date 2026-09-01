# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-01

## Context
The application requires containerised workloads for microservices. The choice is between ECS Fargate, ECS EC2, or Lambda. Each offers different trade-offs in operational overhead, cost, and performance characteristics.

## Decision
ECS Fargate was selected to abstract away the underlying EC2 instance management. This allows the team to focus on deploying and scaling containerised applications without the burden of patching, scaling, or managing the EC2 instances themselves. This decision aligns with the goal of simplifying operations for the microservices platform.

## Consequences
- **Positive**: Reduced operational overhead by eliminating EC2 instance management.
- **Positive**: Simplified scaling of containerised applications.
- **Negative**: Potential for cold start latency compared to provisioned EC2 instances.
- **Negative**: Potentially higher cost for consistent, high-utilization workloads compared to EC2.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
ECS Fargate costs are included in the total estimate of $800.53/month.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.