# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-10

## Context
A secure and highly available network infrastructure is required for a multi-tier application. This includes defining IP addressing, subnet strategy, and internet access control across multiple Availability Zones.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established, utilizing two Availability Zones ('a' and 'b'). The subnet strategy employs public subnets (10.0.1.0/24, 10.0.2.0/24) for internet-facing resources like the ALB and NAT gateways, and private subnets (10.0.11.0/24, 10.0.12.0/24) for application and database tiers. Two NAT gateways, one in each AZ, provide outbound internet access for private resources.

## Consequences
- **Positive**: Enhanced security by isolating application and database tiers in private subnets.
- **Positive**: High availability achieved through multi-AZ deployment of subnets and NAT gateways.
- **Positive**: Granular control over network traffic flow.
- **Negative**: Increased complexity in network configuration and management.
- **Negative**: NAT Gateway costs add to the overall infrastructure expenses.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
The NAT Gateways are a component of the total $1089.93/month cost.

## Security Findings
N/A for this ADR.