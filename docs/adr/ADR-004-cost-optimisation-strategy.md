# ADR-004: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-16

## Context
The project aims to be cost-effective for a production environment, balancing performance and operational overhead with expenditure. Key components like API Gateway and Lambda have variable pricing models that can be optimised.

## Decision
The architecture leverages serverless components (API Gateway HTTP API and Lambda) with pay-per-use pricing. DynamoDB is configured with 'PAY_PER_REQUEST' billing. This approach inherently optimises costs by aligning expenditure with actual usage, avoiding the need to provision and pay for idle capacity typical of traditional server-based architectures.

## Consequences
- **Positive**: Cost scales directly with usage, eliminating costs associated with idle resources. Reduced operational overhead contributes to lower total cost of ownership.
- **Negative**: For consistently high, predictable workloads, provisioned capacity might offer lower per-request costs (though this is less common in pure serverless API patterns).

## Agents Involved
Prism, Atlas, Scribe

## Cost Impact
The total estimated monthly cost is $28.45, reflecting the cost-optimised serverless design. This estimate includes API Gateway requests, Lambda compute, and DynamoDB on-demand throughput.

## Security Findings
N/A for this ADR