# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-16

## Context
The application requires a NoSQL database to store and retrieve data for the serverless API. Key requirements include scalability, flexible schema, and integration with AWS Lambda.

## Decision
Amazon DynamoDB was selected as the database engine. Its fully managed nature, 'on-demand' capacity mode, and seamless integration with Lambda make it an ideal fit for a serverless architecture. The 'PAY_PER_REQUEST' billing mode aligns with the serverless, event-driven model.

## Consequences
- **Positive**: Fully managed service, high scalability, pay-per-request pricing aligns with serverless model, low-latency performance.
- **Negative**: NoSQL schema can be challenging for complex relational queries, potential for high costs if not managed carefully.

## Agents Involved
Atlas, Scribe

## Cost Impact
DynamoDB costs are based on read/write capacity units and storage. The 'PAY_PER_REQUEST' mode optimizes cost for unpredictable workloads.

## Security Findings
N/A for this ADR.