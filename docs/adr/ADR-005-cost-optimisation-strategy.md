# ADR-005: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-09

## Context
While performance and availability are critical, cost efficiency is also a consideration. This ADR outlines the cost-related decisions made during architecture design.

## Decision
The architecture aims for a balance between cost and performance. Specific instance types and resource configurations were chosen based on the estimated workload requirements to avoid over-provisioning. The total estimated cost is $208.43/month.

## Consequences
- **Positive**: Cost-effective deployment aligned with the estimated resource needs.
- **Negative**: Potential for suboptimal performance if workload demands exceed initial estimates. Opportunities for further optimization may exist.

## Agents Involved
Prism, Scribe

## Cost Impact
The estimated monthly cost for this infrastructure is $208.43.

## Security Findings
N/A