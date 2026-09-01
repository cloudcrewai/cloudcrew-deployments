# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-01

## Context
The microservices platform requires a relational database to store application data. The primary considerations are data integrity, scalability, performance, and managed service capabilities.

## Decision
PostgreSQL was selected as the relational database engine. This decision leverages a robust, open-source, and ACID-compliant database known for its extensibility and strong community support. Utilizing RDS for PostgreSQL provides managed patching, backups, and scaling, reducing operational burden.

## Consequences
- **Positive**: Robust data integrity and ACID compliance.
- **Positive**: Mature feature set and wide compatibility.
- **Positive**: Managed service benefits from RDS (backups, patching, scaling).
- **Negative**: Potential for higher costs compared to self-managed solutions.
- **Negative**: Vendor lock-in to AWS RDS ecosystem.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
RDS PostgreSQL costs are part of the total estimate of $800.53/month.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.