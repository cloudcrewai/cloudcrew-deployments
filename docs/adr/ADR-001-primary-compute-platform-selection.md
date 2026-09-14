# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-14

## Context
The application requires containerised workloads for its web and application tiers. The primary decision is between EC2-backed ECS, Fargate, and Lambda for hosting these containers.

## Decision
ECS Fargate was selected to abstract away the underlying EC2 instance management. This allows the team to focus on application deployment rather than infrastructure patching and scaling of the compute instances. Fargate provides a serverless compute engine for containers, simplifying operations.

## Consequences
- **Positive**: Reduced operational overhead due to no EC2 instance management.
- **Positive**: Simplified scaling of containerized applications.
- **Negative**: Potentially higher cost for sustained, high-utilization workloads compared to optimized EC2 instances.
- **Negative**: Less control over the underlying compute environment.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
ECS Fargate contributes to the total estimated cost of $1081.93/month.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.