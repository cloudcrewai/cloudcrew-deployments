# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-14

## Context
The application requires a relational database to store persistent data. The choice involves selecting an appropriate managed database service and engine that balances performance, scalability, and operational ease.

## Decision
RDS PostgreSQL was selected as the relational database engine. PostgreSQL offers a robust set of features, strong ACID compliance, and good performance characteristics suitable for a variety of applications. RDS provides managed operations, including patching, backups, and high availability.

## Consequences
- **Positive**: Mature and feature-rich open-source relational database.
- **Positive**: Managed service reduces operational burden.
- **Positive**: Supports high availability configurations.
- **Negative**: Can be more expensive than self-managed databases for certain workloads.
- **Negative**: Potential for vendor lock-in with managed services.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
RDS PostgreSQL is a significant contributor to the total estimated cost of $1081.93/month.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.