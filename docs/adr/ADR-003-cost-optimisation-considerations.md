# ADR-003: Cost Optimisation Considerations

## Status
Accepted

## Date
2026-09-01

## Context
The HIPAA Data Governance Platform aims to balance security and compliance requirements with cost efficiency. The infrastructure selection and configuration are reviewed to ensure resources are appropriately sized and utilized.

## Decision
The current infrastructure is designed with essential services for HIPAA compliance, including an S3 data lake, KMS, AWS Config, GuardDuty, CloudTrail, and Amazon Transcribe. The pricing estimate reflects the utilisation of these services. Specific instance types or auto-scaling configurations are not detailed in the blueprint for compute services, as the 'compute_class' is 'none'.

## Consequences
- **Positive**: Core HIPAA compliance services are included to meet regulatory requirements.
- **Negative**: Without detailed compute resource specifications, specific right-sizing or Graviton adoption cannot be evaluated.
- **Negative**: The cost estimate of $66.70/month is a baseline and may increase with data volume and processing demands.

## Agents Involved
Prism, Scribe

## Cost Impact
The estimated monthly cost for the core services is $66.70.

## Security Findings
N/A