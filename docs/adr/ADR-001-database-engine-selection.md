# ADR-001: Database Engine Selection

## Status
Accepted

## Date
2026-09-09

## Context
The project requires a relational database to support core application data storage. Key requirements include high availability, performance for read and write operations, and compatibility with PostgreSQL applications. The decision focused on selecting a managed database service that minimizes operational overhead while providing robust features.

## Decision
Amazon Aurora PostgreSQL was selected as the database engine. This choice leverages Aurora's compatibility with PostgreSQL, offering enhanced performance and availability over standard PostgreSQL instances. Its managed nature reduces the burden of infrastructure management, patching, and backups.

## Consequences
- **Positive**: Improved performance and availability compared to standard PostgreSQL.
- **Positive**: Reduced operational overhead due to managed service.
- **Negative**: Potential for higher cost compared to self-managed PostgreSQL.
- **Negative**: Vendor lock-in to AWS Aurora.

## Agents Involved
Atlas, Scribe

## Cost Impact
Cost is determined by instance size, storage, and I/O, which are detailed in the <cost_estimate>.

## Security Findings
No specific findings related to database engine selection are reported in the <shield_summary> or <warden_summary>.