# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-16

## Context
The IoT data pipeline needs to store processed data in two distinct formats: aggregated data suitable for quick lookups and real-time analytics, and time-series data for historical trend analysis. The chosen databases must support these different data models and provide scalable performance.

## Decision
DynamoDB was selected for storing aggregated data due to its NoSQL key-value nature, offering high scalability and low-latency access for lookups. Timestream was chosen for storing time-series metrics, providing a purpose-built, scalable database optimized for time-stamped data and analytical queries over time ranges.

## Consequences
- **Positive**: Optimized storage and query performance for different data types, managed scalability for both databases.
- **Negative**: Potential for increased operational complexity managing two distinct database services.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
DynamoDB costs are estimated at $43.20/month, and Timestream costs at $39.00/month, totaling $82.20/month based on Prism's estimate.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.