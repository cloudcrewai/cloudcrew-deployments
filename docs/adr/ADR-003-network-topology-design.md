# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-18

## Context
The application needs a secure and highly available network architecture across multiple Availability Zones (AZs). This involves defining the VPC CIDR range, subnet strategy (public for internet-facing resources, private for application and database tiers), and the placement of NAT Gateways for outbound internet access from private subnets.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established. Two public subnets (10.0.1.0/24 and 10.0.2.0/24) and two private subnets for application services (10.0.11.0/24 and 10.0.12.0/24) were provisioned across two AZs ('a' and 'b'). Two NAT Gateways, one in each public subnet, were deployed to facilitate outbound internet connectivity for resources in the private subnets.

## Consequences
- **Positive**: Provides network isolation between tiers.
- **Positive**: Enables high availability by spanning resources across multiple AZs.
- **Positive**: Secure outbound internet access for private resources.
- **Negative**: Increased complexity in network routing and management compared to a single AZ or simpler subnet strategy.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
The network infrastructure, including NAT Gateways, contributes to the total estimated cost of $1157.60/month.

## Security Findings
N/A