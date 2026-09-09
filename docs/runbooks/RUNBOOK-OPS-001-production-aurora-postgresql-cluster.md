# Runbook: Production Aurora PostgreSQL Cluster

## Overview
This Aurora PostgreSQL cluster provides a highly available and durable relational database solution. It is configured with one writer instance and two reader instances spread across two Availability Zones for fault tolerance. RDS Proxy is employed for efficient connection management and IAM authentication, enhancing security and scalability. Data is encrypted at rest using AWS KMS, and comprehensive logging and monitoring are enabled.

## Prerequisites
- AWS CLI configured with appropriate IAM permissions for RDS, Secrets Manager, KMS, and CloudWatch.
- Network connectivity to the VPC where the RDS instance resides.
- IAM user or role with permissions to access Secrets Manager for retrieving database credentials.
- Understanding of PostgreSQL client tools.

## Architecture
The Aurora PostgreSQL cluster is deployed within a private subnet across two Availability Zones (AZ-A and AZ-B) within the 'App VPC'. NAT Gateways in each AZ provide outbound internet access for patching and updates. RDS Proxy sits in front of the cluster, managing connections and enforcing IAM authentication. AWS KMS is used for encryption at rest. CloudWatch is configured for logging and monitoring.

## Operations

### Scaling
1. **Manual Scaling (Instances):**
   a. Navigate to the RDS console.
   b. Select the Aurora cluster.
   c. Choose 'Modify'.
   d. Adjust the 'DB instance class' for writer and reader instances as needed. Note that changing the instance class requires a downtime window.
2. **Auto Scaling (Read Replicas - not directly configurable for Aurora writer, but read capacity can scale):**
   a. Aurora's architecture inherently scales read capacity. For more granular control or specific read scaling needs, consider adding more reader instances manually or through custom automation scripts that monitor read load and add/remove instances.

### Monitoring
Key CloudWatch metrics to monitor:
- `CPUUtilization`: Monitor for sustained high CPU on writer and reader instances (e.g., alarm > 80% for 15 minutes).
- `DatabaseConnections`: Track the number of active connections to identify potential connection pool exhaustion or inefficient queries (e.g., alarm > 85% of max connections).
- `ReadIOPS` and `WriteIOPS`: Monitor disk I/O to identify performance bottlenecks.
- `AuroraConnections`: Monitor connections specifically through RDS Proxy.
- `FreeableMemory`: Ensure sufficient memory is available (e.g., alarm < 10% for 15 minutes).
- `DiskQueueDepth`: Indicates I/O pressure.

### Backup & Recovery
Aurora automatically performs daily backups and retains them for a configurable period (default is 7 days). Point-in-time recovery (PITR) is enabled, allowing restoration to any second within the retention period. 
**RPO:** The Recovery Point Objective is typically seconds due to Aurora's continuous backup mechanism. 
**RTO:** Recovery Time Objective depends on the size of the database and instance class, but is generally within minutes for a PITR. 
**Restore Procedure:**
1. Navigate to the RDS console.
2. Select the Aurora cluster.
3. Choose 'Restore to point in time'.
4. Select the desired timestamp and launch a new cluster.

### Common Issues
### High CPU Utilization
*   **Diagnosis:** CloudWatch `CPUUtilization` metric is consistently high (>80%).
*   **Resolution:** Analyze slow query logs, optimize application queries, consider upgrading the instance class, or scale read replicas if read load is the primary cause.

### High `DatabaseConnections` or `AuroraConnections`
*   **Diagnosis:** Connection count is near the maximum allowed, or the application reports connection timeouts.
*   **Resolution:** Ensure the application properly closes connections. Implement connection pooling using RDS Proxy or within the application. Check for inefficient application logic that holds connections open longer than necessary.

### Slow Query Performance
*   **Diagnosis:** Specific queries are taking a long time to execute, impacting application performance.
*   **Resolution:** Enable and analyze the slow query log. Use `EXPLAIN` statements to understand query execution plans. Add or modify database indexes. Refactor inefficient queries.

### Replication Lag (for Reader Instances)
*   **Diagnosis:** Reader instances are falling behind the writer instance, observable via CloudWatch metrics like `AuroraReplicationLag`.
*   **Resolution:** Ensure reader instances are appropriately sized. Check network latency between writer and readers. Analyze read load on the readers; if consistently high, consider adding more reader instances.

## Rollback Procedure
1. **Database Schema Changes:** If the issue is related to a recent schema deployment, restore the database to a point in time *before* the change using the 'Restore to point in time' procedure.
2. **Infrastructure Changes:** Revert the IaC changes in the Git repository.
3. **Apply Reverted IaC:** Execute `terraform apply` (or the relevant IaC command) to redeploy the previous infrastructure state.
4. **Verify Service Health:** Confirm that the database is accessible and the application can connect and function correctly.

## Contacts
Generated by CloudCrew AI — 2026-09-09