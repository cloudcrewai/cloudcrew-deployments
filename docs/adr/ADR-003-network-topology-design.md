# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-19

## Context
A secure and scalable network architecture is essential for the three-tier application. This involves defining the VPC CIDR range, subnet strategy, and the placement of NAT Gateways for outbound internet access from private resources.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established, utilizing two Availability Zones (a and b) for high availability. The subnet strategy includes public subnets (10.0.1.0/24, 10.0.2.0/24) for internet-facing resources like the ALB, and private subnets (10.0.11.0/24, 10.0.12.0/24) for application and database tiers. NAT Gateways are deployed in each Availability Zone (AZ-A and AZ-B) within the public subnets, enabling private resources to initiate outbound traffic to the internet while remaining inaccessible from it.

## Consequences
- **Positive**: Enhanced security by isolating application and database tiers in private subnets.
- **Positive**: High availability through resource distribution across two AZs.
- **Positive**: Scalable IP address space with /16 CIDR block.
- **Positive**: Reliable outbound internet connectivity for private resources via NAT Gateways.
- **Negative**: Increased complexity and cost associated with multiple NAT Gateways.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
The network topology, including NAT Gateways and multiple subnets across AZs, influences the overall $1157.60 monthly cost estimate.

## Security Findings
None