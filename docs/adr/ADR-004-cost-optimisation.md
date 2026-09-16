# ADR-004: Cost Optimisation

## Status
Accepted

## Date
2026-09-16

## Context
The project aims for a cost-effective serverless architecture. Key cost drivers include API Gateway requests, Lambda function execution, and DynamoDB throughput.

## Decision
The chosen architecture leverages serverless components (API Gateway, Lambda, DynamoDB) with PAY_PER_REQUEST billing where applicable. Lambda is configured with 512MB memory, balancing performance and cost. API Gateway is an HTTP API, which is generally more cost-effective than REST APIs for high-volume traffic. The pricing hints in the blueprint suggest an expected traffic volume that aligns with these choices.

## Consequences
- **Positive**: Pay-per-use model ensures costs scale with actual usage. Reduced operational costs due to managed services. Cost-effective for variable or unpredictable workloads.
- **Negative**: Costs can escalate rapidly with unexpected high traffic if not monitored. Optimising DynamoDB access patterns is crucial for cost management at scale.

## Agents Involved
Prism, Scribe

## Cost Impact
Total estimated cost is $28.45/month, with Lambda at $1.42/month, DynamoDB at $1.03/month, and API Gateway at $5/month (based on 5M requests). Other services like Route53, ACM, Cognito, EventBridge, SQS, Secrets Manager, KMS, and CloudWatch contribute to the remaining costs.

## Security Findings
N/A