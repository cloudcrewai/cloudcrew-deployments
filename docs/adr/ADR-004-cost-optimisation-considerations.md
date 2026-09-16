# ADR-004: Cost Optimisation Considerations

## Status
Accepted

## Date
2026-09-16

## Context
While building a production-grade serverless API, it's important to consider cost implications and ensure efficient resource utilization. This ADR outlines the cost-related decisions made during the architecture design.

## Decision
The architecture leverages serverless services like API Gateway and Lambda, which inherently offer pay-per-use pricing, aligning costs with actual usage. DynamoDB is configured with PAY_PER_REQUEST billing mode to avoid over-provisioning capacity. Lambda memory is set at 512MB, a balance between performance and cost.

## Consequences
- **Positive**: Costs scale directly with usage, reducing expenditure during low-traffic periods. No idle resource costs for compute and database.
- **Negative**: Costs can become unpredictable with sudden traffic spikes if not properly monitored. Potential for unexpected high costs if runaway processes or inefficient queries occur.

## Agents Involved
Prism, Scribe

## Cost Impact
The estimated total monthly cost for this production serverless API is $29.12. This estimate is based on the provided pricing hints for API Gateway, Lambda, and the selected DynamoDB configuration.

## Security Findings
N/A