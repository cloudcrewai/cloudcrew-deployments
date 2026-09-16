# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-16

## Context
The IoT data pipeline requires a compute platform to process telemetry data received from AWS IoT Core. The processing involves real-time transformations and writing data to both a key-value store (DynamoDB) and a time-series database (Timestream). The selected platform needs to handle variable workloads efficiently and scale automatically based on incoming data volume.

## Decision
AWS Lambda was chosen as the compute platform for the IoT data pipeline. Its event-driven nature is ideal for reacting to new data in Kinesis Data Streams. Lambda provides automatic scaling, pay-per-execution pricing, and managed infrastructure, aligning with the need for efficient and scalable processing of IoT telemetry.

## Consequences
- **Positive**: Eliminates server management, automatic scaling handles fluctuating loads, cost-effective for event-driven workloads.
- **Negative**: Potential for cold starts, execution duration limits, and managing complex dependencies within a single function.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
Lambda costs are estimated at $0.50/month based on Prism's estimate, primarily driven by function invocations and duration.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.