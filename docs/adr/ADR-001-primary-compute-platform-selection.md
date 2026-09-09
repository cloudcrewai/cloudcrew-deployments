# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-09

## Context
The application requires containerized workloads to serve web traffic and run backend processes. The choice of compute platform impacts operational overhead, scaling capabilities, and cost. Options considered were EC2 instances managed by Auto Scaling Groups, ECS Fargate, and Lambda.

## Decision
EC2 instances managed by an Auto Scaling Group were selected. This provides a stable and configurable environment for predictable workloads, allowing for fine-grained control over instance types and operating systems, which is beneficial for a traditional three-tier architecture.

## Consequences
- **Positive**: Full control over the underlying compute environment, familiar management model for EC2.
- **Negative**: Increased operational overhead for patching and managing EC2 instances, potential for underutilization if not right-sized correctly.

## Agents Involved
Atlas, Forge, Prism, Scribe

## Cost Impact
EC2 instances contribute significantly to the total estimated cost of $208.43/month.

## Security Findings
N/A