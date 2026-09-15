# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-15

## Context
The application requires containerised workloads to host the web and API tiers. The choice is between EC2-backed ECS, ECS Fargate, or AWS Lambda. The primary concerns are operational overhead, scalability, and cost-effectiveness for a production environment.

## Decision
ECS Fargate was selected for the web and API tiers. This abstracts away the underlying EC2 instance management, allowing the team to focus on deploying and scaling containers. Fargate provides a serverless compute engine for containers, simplifying operations and offering a pay-for-what-you-use model.

## Consequences
- **Positive**: Reduced operational burden due to no EC2 instance management.
- **Positive**: Seamless scaling of containerized applications.
- **Negative**: Potential for higher costs at very high, consistent utilization compared to optimized EC2.
- **Negative**: Less control over the underlying compute environment compared to EC2-backed ECS.

## Agents Involved
Atlas, Forge, Prism, Scribe

## Cost Impact
ECS Fargate costs are a significant portion of the total estimated $1091.93/month.

## Security Findings
No critical findings from Shield. Warden verdict: APPROVE.