# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-17

## Context
The application's compute layer requires a scalable and managed container orchestration platform to host the web application services. The primary considerations are ease of management, scalability, and integration with other AWS services.

## Decision
ECS Fargate was selected as the compute platform. This choice eliminates the need for managing underlying EC2 instances, allowing the team to focus on deploying and scaling containers. It offers a serverless compute engine for containers, simplifying operations and providing automatic scaling capabilities.

## Consequences
- **Positive**: Reduced operational overhead due to no EC2 instance management.
- **Positive**: Seamless integration with other AWS services within the VPC.
- **Negative**: Potential for slightly higher cost compared to self-managed EC2 for very consistent high-utilization workloads.
- **Negative**: Less control over the underlying infrastructure compared to EC2-backed ECS.

## Agents Involved
Atlas, Forge, Prism, Scribe

## Cost Impact
ECS Fargate contributes to the total estimated cost of $1160.22/month, with costs driven by vCPU and memory usage of the running tasks.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.