# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-12

## Context
The microservices platform requires a robust, scalable, and managed relational database to support transactional data. High availability and data durability are critical for production workloads.

## Decision
Aurora PostgreSQL was selected as the database engine. This managed relational database service offers enhanced performance, availability, and durability compared to standard PostgreSQL. It integrates seamlessly with AWS services and provides features suitable for production microservices.

## Consequences
- **Positive**: High availability and fault tolerance across multiple Availability Zones.
- **Positive**: Automated backups, patching, and scaling.
- **Positive**: Enhanced performance and throughput for PostgreSQL workloads.
- **Negative**: Potentially higher cost than self-managed PostgreSQL or other simpler database solutions.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
Cost is determined by Aurora instance class, storage, and I/O operations. Refer to Prism for detailed estimates.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.