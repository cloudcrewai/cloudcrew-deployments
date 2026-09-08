# ADR-002: Network Topology Design

## Status
Accepted

## Date
2026-09-08

## Context
The project requires a secure and scalable network infrastructure for a production environment. Key requirements include isolation of resources, internet accessibility for specific services, and high availability across multiple Availability Zones.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established across 3 Availability Zones. The topology includes public subnets for internet-facing resources, private subnets for application tiers, and dedicated database subnets. NAT Gateways are placed in public subnets to facilitate outbound internet access for private resources. An Internet Gateway is provisioned for access to the internet.

## Consequences
- **Positive**: Segregated network environments improve security.
- **Positive**: Multi-AZ deployment enhances availability.
- **Positive**: NAT Gateways provide controlled outbound internet access.
- **Negative**: NAT Gateways incur additional costs.
- **Negative**: Managing a large CIDR block requires careful planning.

## Agents Involved
Atlas, Scribe

## Cost Impact
VPC, subnets, NAT Gateways, and associated data transfer contribute to the overall cost.

## Security Findings
No specific security findings related to network topology were provided.