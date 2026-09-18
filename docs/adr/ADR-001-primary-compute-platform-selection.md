# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-18

## Context
The application requires containerised workloads for the web and API tiers. The choice is between EC2 instances managed by ECS, AWS Lambda for serverless functions, or ECS Fargate for a serverless container experience. High availability and simplified operational management are key considerations.

## Decision
ECS Fargate was selected for the application's compute platform. This abstracts away the underlying EC2 instance management, allowing the operations team to focus on application deployment and scaling rather than infrastructure patching and maintenance. It provides a serverless operational model for containers.

## Consequences
- **Positive**: Reduced operational overhead due to no EC2 instance management.
- **Positive**: Simplified scaling of containerised applications.
- **Negative**: Potential for higher costs compared to EC2 if resource utilization is consistently low.
- **Negative**: Less control over the underlying compute environment.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
ECS Fargate contributes to the total estimated cost of $1157.60/month.

## Security Findings
N/A