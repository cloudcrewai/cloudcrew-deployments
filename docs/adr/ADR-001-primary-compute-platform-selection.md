# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-16

## Context
The project requires a compute platform for running the API handler logic. The architecture pattern is API Gateway microservices, which typically involves event-driven compute. Scalability and operational overhead are key considerations.

## Decision
AWS Lambda was selected as the compute platform. Its serverless nature aligns perfectly with the API Gateway microservices pattern, offering automatic scaling, pay-per-invocation pricing, and eliminating the need for server management. This choice supports the project's goal of a low-operational overhead infrastructure.

## Consequences
- **Positive**: Automatic scaling to handle unpredictable traffic. Reduced operational burden due to no server management. Cost-effective for spiky or low-traffic workloads.
- **Negative**: Potential for cold starts impacting latency for infrequently invoked functions. Execution duration limits can constrain long-running tasks. Vendor lock-in to the Lambda service.

## Agents Involved
Atlas, Forge, Prism, Scribe

## Cost Impact
Lambda costs are estimated at $1.42/month based on 5M invocations, 512MB memory, and 150ms average duration.

## Security Findings
N/A