# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-16

## Context
The IoT data pipeline is a production system processing a high volume of data. Cost efficiency is important, but must be balanced with performance and scalability requirements. Optimisation efforts should focus on leveraging managed services and appropriate resource configurations.

## Decision
The compute platform was selected as Lambda, which offers a pay-per-use model ideal for event-driven, variable workloads, avoiding the cost of idle EC2 instances. DynamoDB and Timestream were chosen for their managed scalability and specific optimisations for their respective data types. The architecture avoids unnecessary provisioned resources, aligning with cost-effective practices.

## Consequences
- **Positive**: Reduced operational overhead by using managed services, pay-per-use compute model is cost-effective for fluctuating loads.
- **Negative**: Potential for higher costs if usage patterns are consistently high and predictable, which might favour provisioned resources.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
The total estimated cost for the production IoT data pipeline is $83.70/month, as per the Prism estimate.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.