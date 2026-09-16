# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-16

## Context
A persistent data store is required to support the serverless API. The database needs to handle high-volume, low-latency read and write operations, scale seamlessly, and be cost-effective for unpredictable workloads. The application pattern suggests a need for flexible schema and easy integration with Lambda.

## Decision
Amazon DynamoDB was selected as the database engine. Its NoSQL nature, 'On-Demand' (Pay-Per-Request) billing mode, and inherent scalability make it ideal for serverless applications with variable traffic. DynamoDB provides single-digit millisecond latency and integrates natively with Lambda via IAM roles.

## Consequences
- **Positive**: Highly scalable, predictable performance, pay-per-request cost model, managed service reducing operational burden, flexible schema.
- **Negative**: Not suitable for complex relational queries or transactions requiring strict ACID compliance across multiple items.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
DynamoDB's PAY_PER_REQUEST billing mode is designed for unpredictable workloads, aligning with the serverless API's potential traffic spikes and ensuring cost efficiency when idle. This contributes to the overall project cost estimate.

## Security Findings
N/A for this ADR