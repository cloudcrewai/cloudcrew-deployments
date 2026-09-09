# ADR-001: Network Topology

## Status
Accepted

## Date
2026-09-09

## Context
The project requires a secure and scalable network infrastructure for ML workloads, necessitating a Virtual Private Cloud (VPC) with isolated subnets for different tiers of access and communication. This includes public subnets for potential ingress/egress points and private subnets for sensitive resources like SageMaker training and inference environments.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established, utilizing two Availability Zones (AZs). Two public subnets (10.0.1.0/24 in AZ-A, 10.0.2.0/24 in AZ-B) and two private subnets (10.0.11.0/24 in AZ-A, 10.0.12.0/24 in AZ-B) were configured. NAT Gateways are deployed in each AZ's public subnet to provide outbound internet access for resources in the private subnets, while keeping them inaccessible from the internet.

## Consequences
- **Positive**: Enhanced security through network isolation.
- **Positive**: Improved availability by spanning across two AZs.
- **Negative**: Increased complexity due to multiple subnets and NAT Gateways.
- **Negative**: Potential for higher costs associated with NAT Gateways.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
The network configuration contributes to the overall cost, with NAT Gateways incurring charges for data processing and hourly usage.

## Security Findings
N/A