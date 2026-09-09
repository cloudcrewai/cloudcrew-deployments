# ADR-003: Cost Optimisation

## Status
Accepted

## Date
2026-09-09

## Context
The objective is to deploy a capable SageMaker ML platform while managing operational expenses. Key cost drivers include data storage, compute resources for training and inference (though compute is managed by SageMaker itself and not explicitly defined here), and data transfer costs.

## Decision
The architecture focuses on cost-effective network access by utilizing VPC endpoints for AWS services, which can reduce data transfer costs compared to accessing services over the public internet. S3 encryption with KMS is implemented, and while KMS incurs some cost, it's essential for security. The overall estimated cost is $67.70/month, reflecting a balance between functionality and expenditure.

## Consequences
- **Positive**: VPC endpoints reduce data transfer costs and improve security. The architecture aims for a predictable monthly cost.
- **Negative**: VPC endpoints can introduce management overhead. KMS usage adds a baseline cost for encryption.

## Agents Involved
Atlas, Prism, Scribe

## Cost Impact
Total estimated cost is $67.70/month. This includes costs associated with VPC endpoints and KMS key usage.

## Security Findings
N/A