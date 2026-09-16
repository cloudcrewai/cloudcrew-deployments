# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-16

## Context
The IoT data pipeline requires a compute platform to process incoming device data. The selection needs to balance scalability, cost-efficiency, and operational overhead for a production environment.

## Decision
AWS Lambda was chosen as the primary compute platform. Its serverless nature eliminates the need for server management, and it automatically scales with incoming request volume, making it well-suited for the variable load of an IoT data pipeline.

## Consequences
- **Positive**: Fully managed, automatic scaling, pay-per-execution pricing model.
- **Negative**: Potential for cold starts, execution duration limits, and complexity in managing state across invocations.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
Lambda costs are estimated at $15.20/month based on the projected invocation count and execution duration within the Prism estimate.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.