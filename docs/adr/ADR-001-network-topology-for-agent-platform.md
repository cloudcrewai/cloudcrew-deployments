# ADR-001: Network Topology for Agent Platform

## Status
Accepted

## Date
2026-09-17

## Context
The AI agent platform requires a secure and scalable network infrastructure. The decision involved selecting appropriate CIDR ranges, subnet strategy, and the placement of network components like NAT Gateways to facilitate outbound internet access for resources within private subnets.

## Decision
A single VPC with a CIDR block of 10.0.0.0/16 was chosen. The network is segmented into public and private subnets, with a NAT Gateway placed in Availability Zone 'a' within the public subnet to manage outbound traffic from the private subnet. This provides a balance between network isolation and necessary external connectivity for services like the AgentCore.

## Consequences
- **Positive**: Provides network segmentation for security.
- **Positive**: NAT Gateway enables controlled outbound internet access for private resources.
- **Negative**: Single AZ deployment limits high availability without further configuration.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
N/A for network topology.

## Security Findings
N/A for network topology.