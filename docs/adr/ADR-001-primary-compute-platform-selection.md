# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-16

## Context
The architecture requires a compute platform for executing API request handlers. Given the serverless API pattern and the need for event-driven execution, various options like EC2-based containers (ECS/EKS) or serverless functions were considered.

## Decision
AWS Lambda was selected as the primary compute platform. Its event-driven nature, automatic scaling, and pay-per-execution pricing model align perfectly with the API Gateway integration and the goal of a highly scalable, cost-effective serverless architecture.

## Consequences
- **Positive**: Eliminates server management overhead, automatic scaling based on demand, cost-efficient for variable workloads.
- **Negative**: Potential for cold starts, execution duration limits, and colder start for infrequent functions.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
Lambda costs are primarily driven by invocation count, duration, and memory allocation. The `lambda_api_handler` is configured with 512MB memory and an average duration of 150ms, with an estimated 5,000,000 invocations per month, contributing to the overall cost.

## Security Findings
N/A