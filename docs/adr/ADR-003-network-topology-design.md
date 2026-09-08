# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-08

## Context
A secure and resilient network architecture is essential for a HIPAA-compliant platform. This includes defining VPC CIDR ranges, subnet strategy, and NAT Gateway placement across multiple Availability Zones.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established. The network utilizes a split of public and private subnets across two Availability Zones ('a' and 'b'). NAT Gateways are deployed in each AZ to provide egress internet access for resources in private subnets while keeping them isolated from direct inbound internet access.

## Consequences
- **Positive**: Enhanced security by isolating resources in private subnets.
- **Positive**: High availability achieved through multi-AZ deployment.
- **Positive**: Controlled outbound internet access via NAT Gateways.
- **Negative**: Increased complexity in network routing and management.
- **Negative**: NAT Gateways introduce a potential single point of failure if not properly managed across AZs.

## Agents Involved
Atlas, Scribe

## Cost Impact
NAT Gateway costs contribute to the overall $788.17/month estimate.

## Security Findings
N/A