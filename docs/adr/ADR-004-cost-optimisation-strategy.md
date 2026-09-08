# ADR-004: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-08

## Context
The goal is to deploy a production-grade environment while being mindful of associated costs. This involves selecting appropriate instance types and service configurations.

## Decision
The current blueprint focuses on establishing a production-ready environment. Specific cost optimisation measures like Graviton instances or aggressive right-sizing were not explicitly detailed in the provided blueprint, but the overall estimated cost is $419.10/month.

## Consequences
- **Positive**: A functional production environment is provisioned.
- **Negative**: Potential for over-provisioning or suboptimal instance choices may lead to increased costs compared to a more aggressively optimised setup.
- **Negative**: Further optimisation efforts may be required post-deployment to fine-tune expenses.

## Agents Involved
Prism, Scribe

## Cost Impact
Total estimated cost is $419.10/month.

## Security Findings
No specific security findings related to cost optimisation were provided.