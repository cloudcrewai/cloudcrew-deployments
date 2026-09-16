# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-16

## Context
The project requires a scalable, event-driven compute platform for handling API requests and background processing. The architecture pattern is API Gateway microservices, suggesting a need for granular, on-demand compute.

## Decision
AWS Lambda was selected as the primary compute platform. This choice aligns with the serverless API Gateway microservices pattern, providing automatic scaling, pay-per-execution pricing, and reduced operational overhead compared to container orchestration or virtual machines.

## Consequences
- **Positive**: Automatic scaling based on demand, reduced operational burden (no servers to manage), cost-effective for spiky or unpredictable workloads.
- **Negative**: Potential for cold starts, limitations on execution duration and package size, vendor lock-in.

## Agents Involved
Atlas, Scribe

## Cost Impact
Lambda costs are primarily driven by invocations, duration, and memory allocation. The provided pricing hints suggest a base cost associated with 5 million invocations and 512MB memory.

## Security Findings
N/A for this ADR.