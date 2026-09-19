# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-19

## Context
A relational database is required for the application's data persistence needs, supporting complex queries and transactional integrity. The selection must consider performance, scalability, reliability, and managed services.

## Decision
RDS PostgreSQL was selected as the database engine. PostgreSQL is a powerful, open-source relational database known for its robustness, extensibility, and support for advanced SQL features. Leveraging RDS provides a managed service that handles patching, backups, and scaling, reducing operational overhead and ensuring high availability for the data tier.

## Consequences
- **Positive**: Robust and feature-rich relational database capabilities.
- **Positive**: Managed service benefits from RDS, including automated backups and patching.
- **Positive**: High availability and durability.
- **Negative**: Potential for higher cost compared to self-hosted open-source solutions.
- **Negative**: Vendor lock-in to AWS RDS.

## Agents Involved
Atlas, Forge, Prism, Scribe

## Cost Impact
The RDS PostgreSQL instance contributes to the overall monthly cost estimate of $1157.60.

## Security Findings
None