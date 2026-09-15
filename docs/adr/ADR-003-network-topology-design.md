# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-15

## Context
The application requires a secure and highly available network infrastructure to support a multi-tier architecture. This includes isolating resources, managing ingress and egress traffic, and ensuring connectivity across multiple Availability Zones for resilience.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was designed, utilizing two Availability Zones (a and b). The topology includes public subnets (10.0.1.0/24 and 10.0.2.0/24) for internet-facing resources like NAT Gateways and ELB, and private subnets (10.0.11.0/24 and 10.0.12.0/24 for AZ B, implicitly) for application and database tiers. NAT Gateways are deployed in each AZ to provide outbound internet access for private resources while maintaining their inaccessibility from the internet.

## Consequences
- **Positive**: Enhanced security through network segmentation with public and private subnets.
- **Positive**: High availability achieved by deploying resources across two Availability Zones.
- **Positive**: Controlled outbound internet access for private resources.
- **Negative**: Increased complexity in managing routing tables and NAT Gateway configurations.
- **Negative**: Potential for higher NAT Gateway costs due to per-hour and data processing charges.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
NAT Gateway costs are a component of the total $1091.93/month estimate.

## Security Findings
N/A for network topology ADR.