# ADR-001: Primary Compute Platform Selection

## Status
Accepted

## Date
2026-09-12

## Context
The project requires a scalable and managed compute environment to host microservices. The primary consideration is to balance operational overhead with performance and cost-efficiency for production workloads.

## Decision
ECS Fargate was selected for the compute platform. This choice provides a serverless compute engine, abstracting away the underlying EC2 instances and simplifying operational management. It supports the requirement for scalable containerized applications without the need for explicit infrastructure provisioning and patching.

## Consequences
- **Positive**: Reduced operational burden due to serverless nature.
- **Positive**: Built-in scaling capabilities aligned with microservice demands.
- **Negative**: Potential for higher per-unit cost compared to EC2-managed instances.
- **Negative**: Less control over the underlying execution environment.

## Agents Involved
Atlas, Forge, Scribe

## Cost Impact
Cost depends on Fargate task usage. Detailed cost analysis for specific task configurations is available from Prism.

## Security Findings
Shield found 0 critical issues. Warden verdict: APPROVE.