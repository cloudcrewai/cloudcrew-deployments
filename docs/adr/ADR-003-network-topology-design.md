# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-14

## Context
A secure and scalable network infrastructure is required to host the application tiers. This involves defining the VPC CIDR, subnet strategy, and internet access points.

## Decision
A single VPC with a CIDR block of 10.0.0.0/16 was established. The network is segmented into public and private subnets across two Availability Zones (a and b). Internet access for private resources is provided via NAT Gateways deployed in each Availability Zone, ensuring high availability and controlled outbound connectivity.

## Consequences
- **Positive**: Segregated network for improved security.
- **Positive**: High availability through multi-AZ subnet design.
- **Positive**: Controlled outbound internet access for private resources.
- **Negative**: NAT Gateways introduce a cost component.
- **Negative**: A single VPC simplifies management but may require careful CIDR planning for future expansion.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
The VPC, subnets, and NAT Gateways contribute to the overall estimated cost of $1081.93/month.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.