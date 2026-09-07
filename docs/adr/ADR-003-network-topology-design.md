# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-07

## Context
A secure and highly available network infrastructure is required for the microservices. This includes defining IP address ranges, subnetting strategy for public and private resources, and ensuring internet accessibility for the public-facing components.

## Decision
A VPC with a /16 CIDR block (10.0.0.0/16) was established. Two Availability Zones are utilized, each with dedicated public and private subnets. NAT Gateways are deployed in each AZ's public subnet to provide outbound internet access for resources in private subnets. This design ensures high availability and network segmentation.

## Consequences
- **Positive**: High availability through multi-AZ deployment.
- **Positive**: Network segmentation via public and private subnets enhances security.
- **Positive**: Outbound internet access for private resources is managed via NAT Gateways.
- **Negative**: NAT Gateways incur additional costs.
- **Negative**: Complexity in managing routing tables across multiple subnets and NAT Gateways.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
NAT Gateway usage contributes to the overall $231.29/month estimate.

## Security Findings
N/A