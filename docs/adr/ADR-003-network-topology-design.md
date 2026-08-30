# ADR-003: Network Topology Design

## Status
Accepted

## Date
2026-08-30

## Context
A secure and scalable network infrastructure is required to host the microservices. This involves defining IP address ranges, subnet strategies, and access control mechanisms. The design must support high availability and isolate different tiers of the application.

## Decision
A three-tier VPC architecture was implemented with a CIDR block of 10.0.0.0/16. The network is segmented into public subnets (10.0.1.0/24, 10.0.2.0/24) for the Application Load Balancer and private subnets (10.0.11.0/24, 10.0.12.0/24) for the ECS services and RDS database. Two NAT gateways, one in each Availability Zone (AZ-A and AZ-B), are deployed in the public subnets to facilitate outbound internet access for resources in private subnets.

## Consequences
- **Positive**: Enhanced security through network segmentation.
- **Positive**: High availability achieved by utilizing two Availability Zones.
- **Positive**: Private subnets provide isolation for sensitive resources like the database.
- **Negative**: Increased complexity in network configuration and management.
- **Negative**: NAT Gateways incur additional costs.

## Agents Involved
Atlas, Scribe

## Cost Impact
The NAT Gateways contribute to the overall network infrastructure costs within the estimated $800.53/month.

## Security Findings
N/A