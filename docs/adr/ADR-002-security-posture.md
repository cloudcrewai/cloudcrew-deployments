# ADR-002: Security Posture

## Status
Accepted

## Date
2026-09-09

## Context
The SageMaker ML platform needs to ensure a secure environment for training and deploying machine learning models. This involves protecting data at rest, controlling network access, and adhering to security best practices. Key aspects include data encryption and network segmentation.

## Decision
The platform leverages a Customer Managed KMS Key for encrypting data stored in S3. Network traffic is controlled through VPC endpoints, ensuring that communication with AWS services remains within the AWS network. The Warden assessment resulted in an 'APPROVE' verdict, indicating adherence to IAM security policies. Shield reported zero critical findings.

## Consequences
- **Positive**: Data at rest is encrypted using a customer-managed key, enhancing data security. VPC endpoints reduce exposure by keeping traffic within the AWS network. Approved IAM configuration minimizes access risks.
- **Negative**: KMS key management requires operational oversight. VPC endpoint policies need careful configuration to balance access and security.

## Agents Involved
Atlas, Shield, Warden, Scribe

## Cost Impact
KMS key usage incurs costs, which are factored into the overall estimate.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.