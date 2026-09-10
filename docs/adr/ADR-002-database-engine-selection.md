# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-10

## Context
A relational database is required to support the application's data persistence needs. The database must be highly available, durable, and scalable for a production environment.

## Decision
Amazon RDS PostgreSQL was chosen as the database engine. PostgreSQL offers a robust feature set suitable for complex queries and data integrity requirements. RDS managed service provides automated patching, backups, and multi-AZ deployments for high availability.

## Consequences
- **Positive**: High availability and durability through RDS managed features.
- **Positive**: Scalability options for compute and storage.
- **Negative**: Potential for higher operational cost compared to self-managed databases.
- **Negative**: Vendor lock-in to AWS RDS ecosystem.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
RDS PostgreSQL contributes to the overall $1089.93/month cost.

## Security Findings
N/A for this ADR.