# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-15

## Context
The application requires a relational database to store structured data for the web application. The chosen database needs to support transactional workloads, provide high availability, and be suitable for a production environment.

## Decision
PostgreSQL was selected as the database engine, deployed on Amazon RDS. PostgreSQL is a robust, open-source relational database known for its reliability, feature set, and extensibility. RDS simplifies the operational management of PostgreSQL, including patching, backups, and high availability.

## Consequences
- **Positive**: Mature, feature-rich relational database.
- **Positive**: Simplified management and high availability via RDS.
- **Positive**: Strong community support and extensive documentation.
- **Negative**: Potential for higher licensing and operational costs compared to some other open-source options if not managed efficiently.

## Agents Involved
Atlas, Scribe

## Cost Impact
RDS PostgreSQL costs are factored into the total estimate of $1091.93/month.

## Security Findings
N/A for database engine selection ADR.