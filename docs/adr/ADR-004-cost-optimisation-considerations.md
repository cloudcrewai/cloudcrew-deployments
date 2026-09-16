# ADR-004: Cost Optimisation Considerations

## Status
Accepted

## Date
2026-09-16

## Context
Evaluating cost-efficiency for the serverless API, considering compute, database, and other managed services.

## Decision
The selection of AWS Lambda and DynamoDB with 'PAY_PER_REQUEST' billing mode inherently provides cost optimisation for variable workloads by aligning costs with actual usage. Focusing on efficient Lambda function code and appropriate memory allocation further contributes to cost-effectiveness.

## Consequences
- **Positive**: Pay-per-use model avoids idle resource costs, scales cost with usage, reduced operational overhead saving on personnel costs.
- **Negative**: Costs can become unpredictable if usage spikes significantly without proper monitoring, requires careful tuning of Lambda memory to balance cost and performance.

## Agents Involved
Prism, Scribe

## Cost Impact
The total estimated cost is $28.45/month, leveraging serverless services for cost efficiency.

## Security Findings
N/A for this ADR.