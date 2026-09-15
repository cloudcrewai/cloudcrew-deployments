# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-15

## Context
The application requires a relational database to store and manage its data. Key considerations include reliability, performance, scalability, and compatibility with the application's data model.

## Decision
PostgreSQL was selected as the database engine. It is a powerful, open-source relational database known for its robustness, extensibility, and ACID compliance. RDS PostgreSQL offers managed capabilities, including automated backups, patching, and multi-AZ deployments for high availability, aligning with production requirements.

## Consequences
- **Positive**: Robust feature set and strong community support for PostgreSQL.
- **Positive**: High availability and durability provided by RDS Multi-AZ deployment.
- **Negative**: Potential for higher operational costs compared to self-managed databases.
- **Negative**: Requires careful schema design and query optimization for performance.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
Cost depends on RDS instance class and storage, not estimated.

## Security Findings
N/A