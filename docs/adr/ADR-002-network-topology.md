# ADR-002: Network Topology

## Status
Accepted

## Date
2026-09-09

## Context
The application requires a secure and highly available network environment. This involves defining the IP address space for the Virtual Private Cloud (VPC) and strategically placing database resources within private subnets to restrict direct public access.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established. The Aurora PostgreSQL cluster is deployed across two Availability Zones (AZs) using private subnets (10.0.11.0/24 and 10.0.12.0/24) to ensure high availability and isolation from public networks.

## Consequences
- **Positive**: Enhanced security by isolating the database in private subnets.
- **Positive**: High availability through multi-AZ deployment.
- **Negative**: Requires careful configuration of network access controls (e.g., Security Groups, NACLs) for authorized access.
- **Negative**: Limited IP address space within subnets if not planned carefully.

## Agents Involved
Atlas, Scribe

## Cost Impact
Network infrastructure costs are generally low, primarily associated with NAT Gateways if outbound internet access is required from private subnets. Specifics are in <cost_estimate>.

## Security Findings
The network topology, placing resources in private subnets, aligns with security best practices. <shield_summary> reported 0 critical findings, and <warden_summary> provided an APPROVE recommendation.