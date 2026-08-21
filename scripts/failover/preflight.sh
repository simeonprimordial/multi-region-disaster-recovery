#!/usr/bin/env bash
set -euo pipefail

# Primary-region failure preflight. This script is intentionally READ-ONLY.
# It does not fence writes, promote Aurora/Redis, change MSK consumers, scale
# EKS, modify Route 53, or set DRServeReady.

INVENTORY="${INVENTORY:-scripts/health-checks/resource-inventory.env}"
[[ -f "$INVENTORY" ]] || { echo "Missing inventory: $INVENTORY" >&2; exit 2; }
# shellcheck disable=SC1090
source "$INVENTORY"

for bin in aws jq curl; do
  command -v "$bin" >/dev/null || { echo "Missing required command: $bin" >&2; exit 2; }
done

printf 'PRE-FLIGHT — READ ONLY — %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
aws sts get-caller-identity

printf '\n== Route 53 health ==\n'
if [[ "${PRIMARY_HEALTH_CHECK_ID:-REPLACE}" != "REPLACE" ]]; then
  aws route53 get-health-check-status --health-check-id "$PRIMARY_HEALTH_CHECK_ID" || true
fi
if [[ "${SECONDARY_HEALTH_CHECK_ID:-REPLACE}" != "REPLACE" ]]; then
  aws route53 get-health-check-status --health-check-id "$SECONDARY_HEALTH_CHECK_ID" || true
fi

printf '\n== Regional endpoint probes ==\n'
curl -fsS --max-time 5 "https://${PRIMARY_FQDN}/health/deep" || echo "PRIMARY_ENDPOINT_UNAVAILABLE"
printf '\n'
curl -fsS --max-time 5 "https://${SECONDARY_FQDN}/health/deep" || echo "SECONDARY_ENDPOINT_UNAVAILABLE"
printf '\n'

printf '\n== Aurora Global Database ==\n'
aws rds describe-global-clusters \
  --region "$DR_REGION" \
  --global-cluster-identifier "$GLOBAL_DB_ID" \
  --query 'GlobalClusters[0].{Status:Status,Members:GlobalClusterMembers[*].{Arn:DBClusterArn,Writer:IsWriter,SynchronizationStatus:SynchronizationStatus}}'

printf '\n== DynamoDB DR replica ==\n'
aws dynamodb describe-table \
  --region "$DR_REGION" \
  --table-name "$DDB_TABLE" \
  --query 'Table.{Status:TableStatus,Replicas:Replicas[*].{Region:RegionName,Status:ReplicaStatus}}'

printf '\n== Redis Global Datastore ==\n'
aws elasticache describe-global-replication-groups \
  --region "$DR_REGION" \
  --global-replication-group-id "$GLOBAL_REDIS_ID" \
  --show-member-info

printf '\n== MSK Replicator ==\n'
aws kafka describe-replicator \
  --region "$DR_REGION" \
  --replicator-arn "$MSK_REPLICATOR_ARN" \
  --query '{State:ReplicatorState,StateInfo:StateInfo,KafkaClusters:KafkaClusters}'

printf '\n== DR EKS control plane ==\n'
aws eks describe-cluster \
  --region "$DR_REGION" \
  --name "$DR_EKS_CLUSTER" \
  --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}'

if command -v kubectl >/dev/null 2>&1; then
  printf '\n== Current kubectl context (informational) ==\n'
  kubectl config current-context 2>/dev/null || true
  printf 'No kubectl mutation is executed by this script.\n'
fi

cat <<'EOF'

PRE-FLIGHT COMPLETE.

This output is evidence for the Incident Commander / technical leads. It is NOT
authorisation to fail over. Failover still requires independent regional-failure
classification, old-primary write fencing, measured replication exposure,
stateful activation, synthetic payment + same-idempotency-key replay, and
DRServeReady before customer DNS exposure.
EOF
