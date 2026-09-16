# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-16

## Context
The project requires a compute platform to host the backend logic for a serverless API. The platform needs to scale automatically with demand and integrate seamlessly with API Gateway. Cost-effectiveness and operational simplicity are also key considerations for a production environment.

## Decision
AWS Lambda was chosen as the compute platform. Its serverless nature eliminates the need for server management, and it integrates directly with API Gateway. Lambda's pay-per-invocation model aligns well with the expected traffic patterns of a serverless API, offering automatic scaling capabilities.

## Consequences
- **Positive**: Fully managed compute, automatic scaling, pay-per-use pricing model, reduced operational overhead.
- **Negative**: Potential for cold starts impacting latency for infrequently invoked functions, execution duration limits.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
Lambda costs are based on invocations, duration, and memory. The estimated cost for 5 million invocations with 512MB memory and 150ms duration is within the total project estimate.

## Security Findings
N/A for this ADR