# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-09

## Context
The three-tier web application requires a relational database to store and manage application data. The options considered were managed database services like Amazon RDS with various engines or self-managed databases on EC2. Key factors included data consistency, reliability, scalability, and operational overhead.

## Decision
Amazon RDS PostgreSQL was selected as the database engine. PostgreSQL offers a robust set of features, strong community support, and is well-suited for complex queries and data integrity requirements. Leveraging RDS provides high availability, automated backups, patching, and other management tasks, reducing the operational burden compared to a self-managed solution.

## Consequences
- **Positive**: High availability and durability with Multi-AZ RDS deployment.
- **Positive**: Automated backups and point-in-time restore capabilities.
- **Positive**: Reduced operational overhead compared to self-managing a database.
- **Negative**: Potential for vendor lock-in with a managed service.
- **Negative**: Can be more expensive than self-managed solutions at extreme scale.

## Agents Involved
Atlas, Scribe

## Cost Impact
RDS PostgreSQL contributes to the overall monthly cost of $1085.93.

## Security Findings
N/A for this ADR.