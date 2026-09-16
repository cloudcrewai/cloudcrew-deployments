# ADR-003: Network Topology

## Status
Accepted

## Date
2026-09-16

## Context
The IoT data pipeline needs a secure and reliable network foundation within AWS. This includes defining IP addressing, subnet strategy, and internet access control for various components.

## Decision
A VPC with a /16 CIDR block (10.0.0.0/16) was established. It utilizes two Availability Zones (a and b) with separate public and private subnets. NAT Gateways in each AZ provide controlled outbound internet access for private resources, and VPC endpoints for S3 ensure private connectivity to the service.

## Consequences
- **Positive**: Enhanced security through private subnets, high availability across AZs, controlled outbound internet access.
- **Negative**: Increased complexity compared to a non-VPC deployment, NAT Gateway costs.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
NAT Gateways and VPC endpoints contribute an estimated $12.10/month to the total cost as per the Prism estimate.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.