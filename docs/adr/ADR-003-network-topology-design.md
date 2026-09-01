# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-01

## Context
A secure and scalable network infrastructure is required for the ECS microservices. This involves defining the VPC CIDR, subnet strategy, and NAT Gateway placement to ensure proper isolation, accessibility, and egress traffic management across multiple Availability Zones.

## Decision
A three-tier VPC network topology was implemented with a /16 CIDR block (10.0.0.0/16). It utilizes public subnets for internet-facing resources like the ALB and private subnets for containerized workloads and the RDS database. Two NAT Gateways, one in each of the two Availability Zones ('a' and 'b'), are deployed in public subnets to provide secure and redundant egress connectivity for resources in private subnets.

## Consequences
- **Positive**: Enhanced security through network segmentation between public and private resources.
- **Positive**: High availability achieved by distributing resources across two Availability Zones.
- **Positive**: Controlled egress traffic via NAT Gateways.
- **Negative**: Increased complexity in network configuration and routing.
- **Negative**: NAT Gateway costs contribute to overall operational expenses.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
Network infrastructure costs (VPC, Subnets, NAT Gateways) are included in the total estimate of $800.53/month.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.