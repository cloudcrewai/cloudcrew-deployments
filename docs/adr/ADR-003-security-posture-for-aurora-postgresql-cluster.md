# ADR-003: Security Posture for Aurora PostgreSQL Cluster

## Status
Accepted

## Date
2026-09-08

## Context
Ensuring the security of the production Aurora PostgreSQL cluster is paramount. This includes data encryption, access control, and monitoring for potential threats.

## Decision
The Aurora cluster is configured with encryption at rest using a dedicated KMS CMK ('KMS Key for Aurora') with key rotation enabled. Credentials are managed via AWS Secrets Manager with automatic rotation. CloudWatch logs for 'postgresql' and 'audit' are exported for monitoring. Shield reported no critical findings, and Warden recommended approval.

## Consequences
- **Positive**: Data at rest is encrypted, secrets management is automated, enhanced security monitoring through log exports, overall security posture approved by Warden.
- **Negative**: Encryption and secrets management introduce some operational overhead, though automated.

## Agents Involved
Atlas, Shield, Warden, Scribe

## Cost Impact
Cost not estimated.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.