# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-09

## Context
The application requires containerized workloads for its web and application tiers. The primary decision was between using Amazon Elastic Container Service (ECS) with Fargate or EC2 launch types, or AWS Lambda. Given the need for long-running processes, persistent connections, and ease of managing application dependencies within containers, ECS was a strong candidate. The choice then narrowed to Fargate versus EC2 for managing the underlying infrastructure.

## Decision
ECS Fargate was selected for the compute platform. This decision was driven by the desire to abstract away the underlying EC2 instance management, reducing operational overhead. Fargate allows the team to focus on deploying and scaling containerized applications without needing to provision, configure, or manage servers.

## Consequences
- **Positive**: Reduced operational burden due to the elimination of EC2 instance management.
- **Positive**: Simplified scaling as Fargate handles capacity provisioning.
- **Negative**: Potentially higher cost compared to EC2 for consistent high utilization workloads (though offset by operational savings).
- **Negative**: Less control over the underlying compute environment compared to EC2.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
Based on the provided cost estimate, ECS Fargate contributes to the overall monthly cost of $1085.93.

## Security Findings
N/A for this ADR.