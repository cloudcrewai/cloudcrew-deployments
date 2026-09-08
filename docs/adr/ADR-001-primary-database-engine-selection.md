# ADR-001: Primary Database Engine Selection

## Status
Accepted

## Date
2026-09-08

## Context
The data platform requires robust, managed relational database capabilities to support various data analytics and processing workloads. The need for high availability, data integrity, and compatibility with existing tooling were key considerations.

## Decision
Aurora PostgreSQL and RDS MySQL were selected to provide a diverse relational database offering. Aurora PostgreSQL offers enhanced performance and availability for transactional workloads, while RDS MySQL caters to specific application requirements and compatibility needs.

## Consequences
- **Positive**: Leverages managed services for reduced operational overhead.
- **Positive**: Provides options for different data needs and compatibility.
- **Negative**: Increased complexity in managing two distinct database services.
- **Negative**: Potential for higher licensing or operational costs compared to a single database type.

## Agents Involved
Atlas, Scribe

## Cost Impact
Database services constitute a significant portion of the total $1518.83/month cost estimate.

## Security Findings
N/A for this ADR.