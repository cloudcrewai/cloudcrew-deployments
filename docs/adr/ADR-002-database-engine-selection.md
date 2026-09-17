# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-17

## Context
The application requires a relational database to store and manage structured data. Key requirements include reliability, scalability, managed services, and support for robust data integrity features.

## Decision
Amazon RDS PostgreSQL was selected for the database engine. PostgreSQL offers a powerful and feature-rich relational database system. Utilizing RDS provides automated management of patching, backups, and scaling, along with Multi-AZ deployment for high availability, aligning with the production-grade requirements.

## Consequences
- **Positive**: High availability and durability with Multi-AZ deployment.
- **Positive**: Managed service reduces operational burden for patching, backups, and failover.
- **Positive**: Robust SQL compliance and advanced features of PostgreSQL.
- **Negative**: Potential for vendor lock-in with the managed RDS service.
- **Negative**: Costs associated with managed database services can be higher than self-hosting.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
RDS PostgreSQL is a significant component of the total estimated cost of $1160.22/month, influenced by instance class and storage.

## Security Findings
N/A