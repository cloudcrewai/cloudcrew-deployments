# ADR-003: Cost Optimisation for Agent Platform

## Status
Accepted

## Date
2026-09-17

## Context
The AI agent platform needs to be cost-effective while meeting production requirements. This decision record outlines the cost considerations, focusing on the selected services and their estimated monthly expenditure.

## Decision
The selected services, including Amazon Bedrock AgentCore, Cognito, Secrets Manager, KMS, and CloudWatch, have been provisioned with configurations tailored for production use. The estimated total cost for this production deployment is approximately $34.85 per month.

## Consequences
- **Positive**: The cost is contained within reasonable limits for a production environment.
- **Positive**: Utilisation of managed services like Bedrock AgentCore and Cognito reduces operational overhead.
- **Negative**: Projected costs may increase with higher usage of AgentCore, requiring ongoing cost monitoring.

## Agents Involved
Prism, Scribe

## Cost Impact
Estimated total cost is $34.85/month.

## Security Findings
N/A for cost optimisation.