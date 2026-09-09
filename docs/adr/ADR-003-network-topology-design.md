# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-09

## Context
The network topology for the three-tier web application needs to provide secure and scalable connectivity between its tiers while ensuring public accessibility for the front-end and isolating backend components. This involves defining the Virtual Private Cloud (VPC) CIDR range, subnet strategy across Availability Zones (AZs), and internet access patterns.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established, utilizing a multi-AZ subnet strategy. Public subnets (10.0.1.0/24 and 10.0.2.0/24) in 'a' and 'b' AZs host the Application Load Balancer (ALB). Private subnets (10.0.11.0/24 and 10.0.12.0/24) in the same AZs host the ECS services and RDS database, ensuring they are not directly exposed to the internet. NAT Gateways are deployed in each AZ ('a' and 'b') within public subnets to provide outbound internet access for resources in private subnets.

## Consequences
- **Positive**: Enhanced security by isolating backend resources in private subnets.
- **Positive**: High availability achieved through multi-AZ deployment of subnets and NAT Gateways.
- **Positive**: Scalable IP address space provided by the 10.0.0.0/16 VPC CIDR.
- **Negative**: Increased complexity due to managing multiple subnets and NAT Gateways.
- **Negative**: NAT Gateway costs are incurred for outbound internet access from private subnets.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
The network infrastructure, including NAT Gateways, contributes to the overall monthly cost of $1085.93.

## Security Findings
N/A for this ADR.