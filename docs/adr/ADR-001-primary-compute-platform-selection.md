# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-08-30

## Context
The project requires a container orchestration platform for microservices. The primary considerations are ease of management, scalability, and operational overhead. The choice needs to balance cost, performance, and the effort required for maintaining the underlying infrastructure.

## Decision
ECS Fargate was selected as the compute platform. This decision was driven by the need to abstract away EC2 instance management, allowing the team to focus on deploying and scaling containers. Fargate provides a serverless compute engine for containers, simplifying operations and reducing the burden of patching and managing underlying infrastructure.

## Consequences
- **Positive**: Reduced operational overhead due to no EC2 instance management.
- **Positive**: Simplified scaling as Fargate manages the underlying capacity.
- **Negative**: Potentially higher cost per unit of compute compared to EC2 for steady-state workloads.
- **Negative**: Less control over the underlying compute environment and instance types.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
ECS Fargate contributes to the total estimated cost of $800.53/month.

## Security Findings
N/A