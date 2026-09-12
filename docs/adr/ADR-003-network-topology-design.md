# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-12

## Context
The network architecture must provide secure, isolated, and highly available connectivity for microservices deployed across multiple Availability Zones. The design needs to accommodate both internal service-to-service communication and controlled external access.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established, utilizing three public and three private subnets spread across three Availability Zones (a, b, c). NAT Gateways are deployed in each AZ for outbound internet access from private subnets. This multi-AZ subnet strategy ensures high availability and resilience.

## Consequences
- **Positive**: High availability and fault tolerance through multi-AZ deployment.
- **Positive**: Network isolation for private subnets enhances security.
- **Positive**: NAT Gateways provide controlled outbound internet connectivity.
- **Negative**: Increased complexity and management overhead compared to a single-AZ deployment.
- **Negative**: Cost associated with NAT Gateways and multiple Availability Zone resources.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
NAT Gateway usage contributes to the overall cost. Refer to Prism for specific NAT Gateway cost estimates.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.