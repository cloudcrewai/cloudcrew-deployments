# ADR-001: Network Topology Design

## Status
Accepted

## Date
2026-09-01

## Context
The HIPAA Data Governance Platform requires a secure and resilient network infrastructure to host sensitive compliance data and processing. This includes isolating resources, managing internet access, and ensuring high availability across multiple Availability Zones.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established. The network utilizes two public subnets (10.0.1.0/24 and 10.0.2.0/24) and two private subnets (10.0.11.0/24 and 10.0.12.0/24) distributed across two Availability Zones (a and b). Two NAT Gateways, one in each Availability Zone, are deployed in the public subnets to facilitate outbound internet access for resources in the private subnets. An Internet Gateway is attached to the VPC for necessary inbound/outbound traffic.

## Consequences
- **Positive**: Enhanced security through subnet isolation and controlled internet access.
- **Positive**: High availability is supported by deploying resources across two Availability Zones.
- **Negative**: Increased complexity and cost due to the use of NAT Gateways.

## Agents Involved
Atlas, Scribe

## Cost Impact
The network infrastructure, including NAT Gateways, contributes to the overall monthly cost.

## Security Findings
N/A