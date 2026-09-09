# ADR-002: Database Engine Selection

## Status
Accepted

## Date
2026-09-09

## Context
The application requires a relational database to store structured data. The selection of the database engine and its configuration must support the transactional needs of a three-tier architecture while ensuring reliability and availability.

## Decision
A PostgreSQL database was selected. PostgreSQL offers robust features, reliability, and broad compatibility, making it suitable for general-purpose relational database needs. The Multi-AZ RDS deployment ensures high availability and durability.

## Consequences
- **Positive**: High availability and data durability due to Multi-AZ deployment. Robust feature set of PostgreSQL.
- **Negative**: Potential for higher costs compared to simpler database solutions. Requires RDS management.

## Agents Involved
Atlas, Prism, Scribe

## Cost Impact
RDS PostgreSQL instance costs are factored into the total estimated cost of $208.43/month.

## Security Findings
N/A