# ADR-002: Network Topology Design

## Status
Accepted

## Date
2026-09-08

## Context
The network architecture needed to provide secure and isolated connectivity for the Aurora PostgreSQL cluster, adhering to high availability principles by spanning multiple Availability Zones.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established. The Aurora cluster is deployed across two private subnets ('Private Subnet AZ-A' with CIDR 10.0.10.0/24 and 'Private Subnet AZ-B' with CIDR 10.0.11.0/24) to ensure high availability. This private subnet strategy restricts direct public access to the database.

## Consequences
- **Positive**: Enhanced security by isolating the database in private subnets, high availability through multi-AZ deployment.
- **Negative**: Requires careful network configuration for application access to the database, potential complexity in managing cross-subnet routing if not already established.

## Agents Involved
Atlas, Scribe

## Cost Impact
Cost not estimated.

## Security Findings
Security findings not applicable to this ADR.