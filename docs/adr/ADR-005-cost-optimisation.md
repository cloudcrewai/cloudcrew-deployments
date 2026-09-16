# ADR-005: Cost Optimisation

## Status
Accepted

## Date
2026-09-16

## Context
Balancing performance and cost is crucial for a production IoT data pipeline. The architecture needs to be efficient while meeting operational requirements.

## Decision
The compute platform was selected as AWS Lambda for its pay-per-execution model, aligning costs with actual usage. Time-series optimized storage in Timestream and appropriate instance sizing for any supporting services (not explicitly detailed in blueprint excerpt) were considered. The overall cost is estimated at $68.40/month.

## Consequences
- **Positive**: Cost-effective for variable workloads, reduced operational overhead for compute.
- **Negative**: Potential for unpredictable costs with sudden traffic spikes if not monitored, requires careful capacity planning for databases.

## Agents Involved
Atlas, Forge, Shield, Warden, Prism, Scribe

## Cost Impact
The total estimated monthly cost is $68.40, with key drivers being Timestream/DynamoDB ($30.10), Lambda ($15.20), NAT Gateways/VPC Endpoints ($12.10), and security services ($11.00).

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.