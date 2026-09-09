# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-09

## Context
The network must provide secure and reliable connectivity for a three-tier application, segmenting resources logically across different availability zones. Key decisions include VPC CIDR, subnet strategy, and NAT Gateway placement for outbound internet access from private subnets.

## Decision
A VPC with a /16 CIDR block (172.16.0.0/16) was established, utilizing two Availability Zones (a and b). Public subnets are designated for internet-facing resources like the ALB, while private subnets host the application and database tiers. NAT Gateways are deployed in each AZ for high availability of outbound traffic from private subnets.

## Consequences
- **Positive**: Enhanced security through network segmentation. High availability achieved by distributing resources across AZs and using redundant NAT Gateways.
- **Negative**: Increased complexity in network configuration. Subnet CIDR allocation needs careful planning to avoid overlap.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
NAT Gateways incur costs, contributing to the overall $208.43/month estimate.

## Security Findings
N/A