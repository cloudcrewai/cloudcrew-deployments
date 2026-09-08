# ADR-001: Primary Database Engine Selection

## Status
Accepted

## Date
2026-09-08

## Context
The project requires a robust, highly available relational database to support the application's data persistence needs. Considerations included performance, scalability, manageability, and compatibility with existing tooling.

## Decision
Aurora PostgreSQL was selected due to its managed nature, high availability features, performance optimizations over standard PostgreSQL, and compatibility with the PostgreSQL ecosystem. The specific version 16.4 was chosen to leverage the latest stable features and performance enhancements.

## Consequences
- **Positive**: Enhanced performance and availability compared to standard PostgreSQL, reduced operational overhead due to managed service, strong PostgreSQL compatibility.
- **Negative**: Potential for vendor lock-in with AWS Aurora, higher cost compared to self-managed PostgreSQL.

## Agents Involved
Atlas, Scribe

## Cost Impact
Cost not estimated.

## Security Findings
Security findings not applicable to this ADR.