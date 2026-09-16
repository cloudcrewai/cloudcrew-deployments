# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-09-16

## Context
The IoT data pipeline requires a secure and reliable network infrastructure within AWS. This includes internet connectivity for AWS IoT Core, isolation for processing resources, and the ability for services to communicate securely. The design must also consider high availability across multiple Availability Zones.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established, featuring two public subnets (10.0.1.0/24, 10.0.2.0/24) and two private subnets (10.0.11.0/24, 10.0.12.0/24) across two Availability Zones ('a' and 'b'). NAT Gateways are deployed in each public subnet for outbound internet access from private resources. VPC endpoints are utilized to keep traffic between services within the AWS network.

## Consequences
- **Positive**: Network isolation for sensitive resources, high availability through multi-AZ deployment, secure in-VPC communication via endpoints.
- **Negative**: Increased complexity due to NAT Gateways and multiple subnet types.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
NAT Gateway costs are estimated at $1.50/month based on Prism's estimate.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.