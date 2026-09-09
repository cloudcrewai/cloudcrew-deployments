# ADR-004: Cost Optimisation Strategy

## Status
Accepted

## Date
2026-09-09

## Context
The project aims to deploy a robust production PostgreSQL cluster while being mindful of operational costs. The selection of services and configurations should balance performance, availability, and expense.

## Decision
The total estimated cost for the Aurora PostgreSQL cluster is $880.46/month. This estimate reflects the chosen Aurora PostgreSQL engine, multi-AZ deployment, and associated networking components like NAT Gateways, which are necessary for the production environment's availability and functionality.

## Consequences
- **Positive**: A highly available and performant database solution is provisioned within a defined budget.
- **Negative**: The cost of managed services and multi-AZ redundancy is inherent to the chosen architecture.

## Agents Involved
Prism, Scribe

## Cost Impact
Total estimated cost: $880.46/month.

## Security Findings
N/A