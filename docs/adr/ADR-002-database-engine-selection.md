# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-16

## Context
The application requires a database to store and retrieve data for the API. The access patterns are primarily key-value lookups and potentially some range queries, with a need for flexible schema and high scalability.

## Decision
DynamoDB was selected as the database engine. Its fully managed, serverless nature, with a PAY_PER_REQUEST billing mode, aligns with the overall serverless architecture. It provides high scalability and availability, suitable for key-value access patterns and schema flexibility.

## Consequences
- **Positive**: Fully managed service requires no operational overhead. Scales automatically to handle high throughput. Flexible schema supports evolving data requirements.
- **Negative**: Can become expensive at very high, consistent throughput if not optimised. Limited query flexibility compared to relational databases. Potential for hot partitions if not designed carefully.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
DynamoDB costs are estimated at $1.03/month based on PAY_PER_REQUEST billing mode.

## Security Findings
N/A