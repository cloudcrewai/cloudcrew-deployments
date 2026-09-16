# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-16

## Context
The application requires a database to store and retrieve data for the API. Key considerations include scalability, performance, data consistency, and operational overhead in a serverless environment.

## Decision
Amazon DynamoDB was chosen as the database engine. Its fully managed nature, automatic scaling (with PAY_PER_REQUEST billing mode), and high availability are well-suited for a serverless architecture. Point-in-time recovery provides data durability.

## Consequences
- **Positive**: Fully managed service, seamless scaling with API traffic, Pay-per-request model aligns with serverless cost structure, built-in high availability.
- **Negative**: NoSQL data model requires careful schema design, potential for increased costs with unpredictable high throughput if not monitored, vendor lock-in.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
DynamoDB costs are determined by read/write capacity units (in PAY_PER_REQUEST mode) and data storage. Point-in-time recovery incurs additional storage costs but provides enhanced data protection.

## Security Findings
N/A