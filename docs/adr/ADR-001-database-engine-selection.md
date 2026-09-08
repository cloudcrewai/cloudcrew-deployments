# ADR-001: Database Engine Selection

## Status
Accepted

## Date
2026-09-08

## Context
The application requires a relational database to store structured data. The primary considerations were durability, performance, manageability, and compatibility with existing systems.

## Decision
A Multi-AZ PostgreSQL instance was selected due to its robust feature set, strong community support, and proven reliability for production workloads. The Multi-AZ configuration provides high availability and automatic failover.

## Consequences
- **Positive**: High availability and durability
- **Positive**: Mature feature set and ecosystem
- **Negative**: Potential for higher operational overhead compared to managed NoSQL solutions
- **Negative**: Specific query patterns might be less performant than highly optimized NoSQL.

## Agents Involved
Atlas, Scribe

## Cost Impact
RDS PostgreSQL instance costs are part of the total $419.10/month estimate.

## Security Findings
No specific security findings related to the database engine choice were provided.