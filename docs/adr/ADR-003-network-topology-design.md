# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-17

## Context
A secure and scalable network architecture is required to host a multi-tier application. The design must support distinct tiers (web, application, data), provide high availability across multiple Availability Zones, and control network traffic effectively.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was designed, utilizing two Availability Zones (a and b). The topology includes public subnets (10.0.1.0/24, 10.0.2.0/24) for internet-facing resources like NAT Gateways and internet gateways, and private subnets for application (10.0.11.0/24, 10.0.12.0/24) and data tiers. NAT Gateways are deployed in each AZ for outbound internet access from private subnets.

## Consequences
- **Positive**: Segregation of resources across public and private subnets enhances security.
- **Positive**: Multi-AZ deployment ensures high availability.
- **Positive**: Centralized VPC management simplifies network configuration.
- **Negative**: Managing a larger CIDR block requires careful planning to avoid exhaustion.
- **Negative**: NAT Gateways introduce a potential single point of failure within an AZ and incur costs.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
NAT Gateways and the network infrastructure contribute to the overall cost, estimated at $1160.22/month.

## Security Findings
N/A