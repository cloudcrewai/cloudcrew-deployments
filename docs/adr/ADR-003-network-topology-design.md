# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-15

## Context
A secure and highly available network infrastructure is required to host the multi-tier application. This involves defining the VPC CIDR block, subnet strategy for different tiers, and ensuring reliable outbound connectivity.

## Decision
A VPC with a /16 CIDR block (10.0.0.0/16) was established. The network is segmented into public subnets for internet-facing resources (e.g., ALB) and private subnets for application and database tiers. Two NAT Gateways, one in each Availability Zone ('a' and 'b'), are deployed in public subnets to provide controlled outbound internet access for resources in private subnets, enhancing security and availability.

## Consequences
- **Positive**: Segmentation of network traffic improves security.
- **Positive**: Multi-AZ deployment of NAT Gateways ensures high availability for outbound traffic.
- **Positive**: Private subnets protect sensitive resources like databases and application servers from direct internet exposure.
- **Negative**: Management of multiple NAT Gateways incurs additional cost.
- **Negative**: CIDR block choice may limit future expansion if not planned carefully.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
NAT Gateway costs apply, not estimated.

## Security Findings
N/A