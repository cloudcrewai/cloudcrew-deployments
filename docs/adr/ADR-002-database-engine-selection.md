# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-08-30

## Context
The application requires a relational database to store structured data. Key requirements include data integrity, reliable performance, and support for complex queries. The choice of database engine impacts operational overhead, feature set, and compatibility with the application stack.

## Decision
A PostgreSQL RDS instance was selected. PostgreSQL is a powerful, open-source relational database known for its robustness, extensibility, and adherence to SQL standards. RDS provides managed database services, handling patching, backups, and scaling, reducing operational burden.

## Consequences
- **Positive**: Robust, feature-rich relational database.
- **Positive**: Managed service reduces operational overhead.
- **Negative**: Potential for vendor lock-in with managed services.
- **Negative**: Can be more expensive than self-hosted alternatives.

## Agents Involved
Atlas, Scribe

## Cost Impact
The RDS PostgreSQL instance is a significant component of the total estimated cost of $800.53/month.

## Security Findings
N/A