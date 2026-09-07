# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-07

## Context
The project requires a scalable and managed compute platform for microservices. The primary considerations are operational overhead, scaling capabilities, and cost-effectiveness for a production environment.

## Decision
ECS Fargate was selected as the compute platform. This choice eliminates the need for managing underlying EC2 instances, simplifying operations and allowing the team to focus on application development. Fargate also provides automatic scaling and integration with other AWS services.

## Consequences
- **Positive**: Reduced operational burden due to managed infrastructure.
- **Positive**: Seamless integration with AWS services like ALB and CloudWatch.
- **Negative**: Potential for longer cold start times compared to provisioned instances.
- **Negative**: Less control over the underlying compute environment.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
ECS Fargate costs are a significant portion of the total $231.29/month estimate.

## Security Findings
N/A