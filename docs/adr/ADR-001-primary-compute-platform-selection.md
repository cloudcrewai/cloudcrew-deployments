# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-15

## Context
The project requires a containerized compute platform for the web application and API tiers. The platform needs to be highly available, scalable, and managed to reduce operational overhead in a production environment.

## Decision
AWS ECS Fargate was selected as the compute platform. This choice allows for running containers without managing the underlying EC2 instances, simplifying operations and enhancing security. Fargate provides a serverless compute engine for containers, aligning with the goal of reducing operational burden for production workloads.

## Consequences
- **Positive**: Reduced operational overhead due to serverless compute.
- **Positive**: Enhanced security by abstracting away instance management.
- **Positive**: Automatic scaling capabilities managed by ECS.
- **Negative**: Potential for increased cost compared to self-managed EC2 instances if utilization is consistently very high.
- **Negative**: Less control over the underlying infrastructure and its configuration.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
ECS Fargate costs are included in the overall estimate of $1091.93/month.

## Security Findings
N/A for compute platform selection ADR.