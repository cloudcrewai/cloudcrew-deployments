# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-08

## Context
The project requires a scalable and managed compute platform for containerized applications. The decision involves selecting between ECS Fargate, ECS EC2, or Lambda based on operational overhead, scalability, and cost.

## Decision
ECS Fargate was chosen for its serverless compute capabilities. This abstracts away the underlying EC2 instance management, allowing the team to focus on deploying and scaling containerized applications without managing infrastructure.

## Consequences
- **Positive**: Reduced operational burden due to no EC2 instance management.
- **Positive**: Seamless scaling of containers.
- **Negative**: Potentially higher cost for sustained high-utilization workloads compared to EC2.
- **Negative**: Limited control over the underlying infrastructure environment.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
ECS Fargate costs are factored into the overall $788.17/month estimate.

## Security Findings
N/A