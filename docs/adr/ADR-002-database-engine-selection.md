# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-15

## Context
The application requires a relational database to store structured data for the core business logic. Key considerations include reliability, performance, scalability, and managed services to reduce operational overhead in a production environment.

## Decision
Amazon RDS for PostgreSQL was selected as the database engine. PostgreSQL offers robust features, excellent performance, and strong community support. RDS provides automated provisioning, patching, backups, and multi-AZ failover, meeting the high availability and operational requirements for a production database.

## Consequences
- **Positive**: High availability and durability with Multi-AZ deployments.
- **Positive**: Reduced operational overhead via managed database services.
- **Positive**: Scalability options for compute and storage.
- **Negative**: Potential for higher costs compared to self-managed databases.
- **Negative**: Vendor lock-in to AWS RDS services.

## Agents Involved
Atlas, Scribe

## Cost Impact
RDS PostgreSQL instance costs are a notable component of the $1091.93/month estimate.

## Security Findings
N/A