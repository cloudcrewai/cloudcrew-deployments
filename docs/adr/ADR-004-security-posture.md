# ADR-004: Security Posture

## Status
Accepted

## Date
2026-09-16

## Context
The production IoT data pipeline processes sensitive device telemetry. Ensuring the security posture involves encrypting data at rest and in transit, and applying appropriate access controls. The security of the network and compute resources must also be validated.

## Decision
The pipeline utilizes KMS for data encryption, VPC endpoints for secure inter-service communication, and adheres to a production deployment tier. AWS IoT Core, Kinesis, Lambda, DynamoDB, and Timestream configurations are managed within a secure VPC network. Security validation was performed by Shield and Warden.

## Consequences
- **Positive**: Data encrypted at rest and in transit, network traffic secured within AWS, validated by security tools.
- **Negative**: Ongoing monitoring and maintenance required to address evolving threats.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
Security services like KMS and VPC endpoints have associated costs, contributing minimally to the overall $83.70/month estimate.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.