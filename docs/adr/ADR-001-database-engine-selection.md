# ADR-001: Database Engine Selection

## Status
Accepted

## Date
2026-09-08

## Context
The project requires a highly available, managed relational database for production workloads. Key considerations include performance, scalability, and operational overhead. The need for PostgreSQL compatibility was a primary driver.

## Decision
Amazon Aurora Serverless v2 PostgreSQL was selected due to its ability to automatically scale compute and storage capacity based on demand, ensuring high availability and performance without manual intervention. This aligns with the 'fallback' architecture pattern by providing a robust and resilient database foundation.

## Consequences
- **Positive**: Automatic scaling reduces operational burden and cost for fluctuating workloads.
- **Positive**: High availability across multiple Availability Zones enhances resilience.
- **Negative**: Serverless v2 can have higher per-request costs compared to provisioned instances for consistent, high-load scenarios.
- **Negative**: Potential for cold starts, though significantly mitigated in v2.

## Agents Involved
Atlas, Scribe

## Cost Impact
The estimated monthly cost for the Aurora Serverless v2 cluster is approximately $257.50.

## Security Findings
None