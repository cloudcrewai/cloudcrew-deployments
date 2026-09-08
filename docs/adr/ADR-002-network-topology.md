# ADR-002: Network Topology

## Status
Accepted

## Date
2026-09-08

## Context
A secure and scalable network architecture is required for the production environment. This involves defining VPC CIDR ranges, subnet strategies for high availability, and controlling internet access for resources.

## Decision
A VPC with a 10.0.0.0/16 CIDR block was established. It utilizes two Availability Zones (A and B) with a pair of public and private subnets in each. High availability is supported by placing NAT Gateways in each AZ, allowing private resources to access the internet while remaining inaccessible from it. Database resources are deployed in dedicated private subnets.

## Consequences
- **Positive**: Private subnets enhance security by isolating sensitive resources like the database.
- **Positive**: Dual NAT Gateways in separate AZs provide redundancy for outbound internet access.
- **Positive**: A /16 CIDR block offers ample space for future expansion.
- **Negative**: Management of multiple NAT Gateways incurs additional cost.
- **Negative**: Careful subnet CIDR planning is required to avoid overlap.

## Agents Involved
Atlas, Scribe

## Cost Impact
None

## Security Findings
None