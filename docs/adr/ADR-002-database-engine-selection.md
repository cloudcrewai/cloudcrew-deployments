# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-18

## Context
The application requires a relational database to store persistent data. Key requirements include support for ACID transactions, data integrity, and scalability. PostgreSQL and MySQL are common choices for such workloads.

## Decision
RDS PostgreSQL was selected as the database engine. PostgreSQL offers robust support for complex queries, advanced data types, and a strong emphasis on data integrity and standards compliance, aligning well with the needs of a multi-tier application.

## Consequences
- **Positive**: Managed service reduces operational burden for patching, backups, and high availability.
- **Positive**: Robust feature set for relational data management.
- **Negative**: Potential for vendor lock-in to AWS RDS ecosystem.
- **Negative**: Can be more expensive than self-managed databases.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
RDS PostgreSQL is a significant component of the total estimated cost of $1157.60/month.

## Security Findings
N/A