# ADR-001: Network Topology

## Status
Accepted

## Date
2026-09-09

## Context
The project requires a robust and secure network foundation for SageMaker ML workloads. The primary considerations are providing internet access for necessary operations while isolating sensitive ML resources and data within private subnets. A multi-Availability Zone (AZ) deployment is crucial for high availability.

## Decision
A VPC with a CIDR block of 10.0.0.0/16 was established across two Availability Zones (a and b). Two public subnets (10.0.1.0/24 and 10.0.2.0/24) and two private subnets (10.0.11.0/24 and 10.0.12.0/24) were created. NAT Gateways are deployed in each AZ's public subnet to enable outbound internet access for resources in private subnets, while an Internet Gateway provides access for any necessary public resources.

## Consequences
- **Positive**: Provides network isolation for ML resources, enables secure access to AWS services via VPC endpoints, and supports high availability through a multi-AZ design.
- **Negative**: Requires careful management of NAT Gateway costs and complexity compared to a simpler public subnet-only architecture.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
The NAT Gateways contribute to the overall cost estimate.

## Security Findings
N/A