# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-08

## Context
A robust and HIPAA-compliant database solution is required to store sensitive healthcare data. The choice needs to balance performance, security, manageability, and cost.

## Decision
RDS PostgreSQL was selected as the database engine. PostgreSQL offers a mature feature set, strong ACID compliance, and robust security options, making it suitable for sensitive healthcare data. It is managed by AWS RDS, reducing operational overhead.

## Consequences
- **Positive**: Leverages a well-established, feature-rich database engine.
- **Positive**: Managed service reduces operational burden.
- **Positive**: Supports encryption at rest and in transit for HIPAA compliance.
- **Negative**: Potential for higher costs compared to self-managed solutions or simpler database types.
- **Negative**: Specific performance tuning may require RDS expertise.

## Agents Involved
Atlas, Scribe

## Cost Impact
RDS PostgreSQL costs are included in the $788.17/month estimate.

## Security Findings
N/A