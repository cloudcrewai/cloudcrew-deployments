# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-15

## Context
A secure and highly available network architecture is required for the three-tier application in production. This involves defining IP address ranges, subnetting strategy across Availability Zones, and controlling inbound and outbound traffic.

## Decision
A VPC with a /16 CIDR block (10.0.0.0/16) was established, utilizing two Availability Zones ('a' and 'b'). The topology includes public subnets (10.0.1.0/24, 10.0.2.0/24) for internet-facing resources like NAT Gateways and the Application Load Balancer, and private subnets (10.0.11.0/24, 10.0.12.0/24) for application and database tiers. Two NAT Gateways, one in each AZ, provide controlled outbound internet access for resources in private subnets.

## Consequences
- **Positive**: Enhanced security by isolating application components in private subnets.
- **Positive**: High availability achieved through multi-AZ subnet design.
- **Positive**: Controlled outbound internet access for private resources.
- **Negative**: Increased complexity in network configuration and routing.
- **Negative**: NAT Gateways introduce a potential cost factor and a single point of failure if not properly managed across AZs.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
NAT Gateway costs contribute to the overall $1091.93/month estimate.

## Security Findings
N/A