# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-07

## Context
The microservices architecture requires a relational database to store structured data. The selection criteria include performance, scalability, reliability, and managed service capabilities for a production environment.

## Decision
RDS PostgreSQL was selected as the database engine. PostgreSQL offers a robust feature set, strong community support, and excellent performance characteristics. Using RDS provides managed capabilities for patching, backups, and high availability.

## Consequences
- **Positive**: Robust relational database features and ACID compliance.
- **Positive**: Managed service reduces operational overhead for database administration.
- **Positive**: High availability configurations are available within RDS.
- **Negative**: Potential for vendor lock-in with AWS RDS.
- **Negative**: Can be more expensive than self-managed database solutions.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
RDS PostgreSQL instance costs contribute to the overall $231.29/month estimate.

## Security Findings
N/A