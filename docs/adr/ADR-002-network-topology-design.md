# ADR-002: Network Topology Design

## Status
Accepted

## Date
2026-09-08

## Context
A secure and highly available network infrastructure is required for the data platform, ensuring isolation of resources while enabling necessary external access and inter-service communication across multiple Availability Zones.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established, utilizing two Availability Zones ('a' and 'b'). The topology includes public subnets (10.0.1.0/24, 10.0.2.0/24) for internet-facing resources, private subnets (10.0.11.0/24, 10.0.12.0/24) for application tiers, and dedicated private subnets (10.0.21.0/24, 10.0.22.0/24) for databases. NAT Gateways are deployed in each AZ (AZ-A, AZ-B) within public subnets to facilitate outbound internet access for resources in private subnets.

## Consequences
- **Positive**: Enhanced security through network segmentation.
- **Positive**: High availability achieved by spanning resources across two AZs.
- **Positive**: Controlled outbound internet access via NAT Gateways.
- **Negative**: Increased complexity in network management and routing.
- **Negative**: Potential for NAT Gateway costs to scale with traffic.

## Agents Involved
Atlas, Scribe

## Cost Impact
NAT Gateways contribute to the overall infrastructure costs.

## Security Findings
N/A for this ADR.