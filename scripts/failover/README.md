# Failover scripts

## `preflight.sh`

Read-only preflight for a primary-Region failure scenario.

- Checks Route 53 health, regional endpoints, Aurora Global DB, DynamoDB replicas, Redis Global Datastore, MSK Replicator, and DR EKS status
- **Does not** promote databases, change DNS, scale clusters, or set readiness flags

Requires a populated `scripts/health-checks/resource-inventory.env` (see example in that directory).
