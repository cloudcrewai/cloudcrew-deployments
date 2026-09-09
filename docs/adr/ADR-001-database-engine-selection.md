# ADR-001: Database Engine Selection

## Status
Accepted

## Date
2026-09-09

## Context
The project requires a relational database that supports high availability, read replicas, and robust performance for a production workload. The need for managed services and automatic scaling is critical for operational efficiency.

## Decision
Amazon Aurora PostgreSQL was selected as the database engine. Its compatibility with PostgreSQL, enhanced performance, and built-in high availability features across multiple Availability Zones make it suitable for production. The blueprint specifies one writer and two reader instances across two AZs.

## Consequences
- **Positive**: High availability and durability with multi-AZ deployment. Improved read performance through reader instances. Managed service reduces operational overhead.
- **Negative**: Can be more expensive than standard PostgreSQL. Vendor lock-in with AWS Aurora.

## Agents Involved
Atlas, Scribe

## Cost Impact
Aurora PostgreSQL costs are a significant portion of the total $880.46/month estimate.

## Security Findings
N/A