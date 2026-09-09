# ADR-002: Network Topology Design

## Status
Accepted

## Date
2026-09-09

## Context
A secure and scalable network infrastructure is required for the production Aurora PostgreSQL cluster. The design must allow for controlled access to the database while ensuring high availability across multiple Availability Zones.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established. It utilizes a public subnet strategy in two AZs (10.0.1.0/24 and 10.0.2.0/24) for NAT Gateways and private subnets in two AZs (10.0.11.0/24 and 10.0.12.0/24) for the database instances. Two NAT Gateways, one in each AZ, provide outbound internet access for instances in private subnets.

## Consequences
- **Positive**: Enhanced security by placing the database in private subnets. High availability achieved through multi-AZ deployment. NAT Gateways enable necessary outbound connectivity without exposing instances directly.
- **Negative**: Increased complexity compared to a single-AZ deployment. NAT Gateways incur additional costs.

## Agents Involved
Atlas, Scribe

## Cost Impact
The multi-AZ subnet strategy and NAT Gateways contribute to the overall $880.46/month cost.

## Security Findings
N/A