# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-16

## Context
The IoT data pipeline requires a database to store device data. The choice must consider data volume, query patterns, and scalability for a production environment. Time-series data storage is a primary concern.

## Decision
AWS Timestream was selected as the primary database for time-series data. Its purpose-built nature for IoT and time-series data offers efficient storage and querying of timestamped data, while DynamoDB is used for metadata and operational state.

## Consequences
- **Positive**: Optimized for time-series data, seamless integration with other AWS IoT services, built-in data lifecycle management.
- **Negative**: Can be more expensive than general-purpose databases for non-time-series workloads, learning curve for specific query language.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
Timestream and DynamoDB costs are estimated at $30.10/month based on data ingestion, storage, and query volume within the Prism estimate.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.