#!/usr/bin/env bash
set -euo pipefail

# Read-only DR readiness check. This script never promotes, modifies, scales,
# reroutes or deletes resources. It is safe only to the extent that the caller's
# AWS/kubectl credentials are themselves read-only/approved for the target env.

INVENTORY="${INVENTORY:-scripts/health-checks/resource-inventory.env}"
[[ -f "$INVENTORY" ]] || { echo "Missing inventory: $INVENTORY" >&2; exit 2; }
# shellcheck disable=SC1090
source "$INVENTORY"

required=(aws jq curl)
for bin in "${required[@]}"; do
  command -v "$bin" >/dev/null || { echo "Missing required command: $bin" >&2; exit 2; }
done

fail=0
pass() { printf 'PASS  %s\n' "$*"; }
warn() { printf 'WARN  %s\n' "$*"; }
fail_check() { printf 'FAIL  %s\n' "$*"; fail=1; }

printf 'DR readiness — %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'Primary=%s  DR=%s\n\n' "$PRIMARY_REGION" "$DR_REGION"

if aws sts get-caller-identity >/dev/null 2>&1; then
  pass "AWS identity resolved"
else
  fail_check "AWS identity unavailable"
fi

if [[ "$GLOBAL_DB_ID" != "REPLACE" ]] && aws rds describe-global-clusters \
    --region "$DR_REGION" \
    --global-cluster-identifier "$GLOBAL_DB_ID" >/dev/null 2>&1; then
  pass "Aurora Global Database visible from DR control plane"
else
  fail_check "Aurora Global Database inventory/control-plane check failed"
fi

if [[ "$DDB_TABLE" != "REPLACE" ]] && aws dynamodb describe-table \
    --region "$DR_REGION" \
    --table-name "$DDB_TABLE" >/dev/null 2>&1; then
  pass "DynamoDB DR replica table visible"
else
  fail_check "DynamoDB DR replica check failed"
fi

if [[ "$GLOBAL_REDIS_ID" != "REPLACE" ]] && aws elasticache describe-global-replication-groups \
    --region "$DR_REGION" \
    --global-replication-group-id "$GLOBAL_REDIS_ID" >/dev/null 2>&1; then
  pass "Redis Global Datastore visible"
else
  fail_check "Redis Global Datastore check failed"
fi

if [[ "$MSK_REPLICATOR_ARN" != "REPLACE" ]] && aws kafka describe-replicator \
    --region "$DR_REGION" \
    --replicator-arn "$MSK_REPLICATOR_ARN" >/dev/null 2>&1; then
  pass "MSK Replicator visible"
else
  fail_check "MSK Replicator check failed"
fi

if [[ "$DR_EKS_CLUSTER" != "REPLACE" ]] && [[ "$(aws eks describe-cluster \
    --region "$DR_REGION" \
    --name "$DR_EKS_CLUSTER" \
    --query 'cluster.status' --output text 2>/dev/null || true)" == "ACTIVE" ]]; then
  pass "DR EKS control plane ACTIVE"
else
  fail_check "DR EKS control plane not ACTIVE or inventory unresolved"
fi

if [[ -n "${SECONDARY_FQDN:-}" ]] && curl -fsS --max-time 5 "https://${SECONDARY_FQDN}/health/deep" | grep -q 'HEALTHY'; then
  pass "DR deep health endpoint returned expected marker"
else
  warn "DR deep health endpoint not yet reachable/implemented"
fi

if [[ "${SECONDARY_HEALTH_CHECK_ID:-REPLACE}" != "REPLACE" ]]; then
  if aws route53 get-health-check-status --health-check-id "$SECONDARY_HEALTH_CHECK_ID" >/dev/null 2>&1; then
    pass "Route 53 secondary calculated health check readable"
  else
    fail_check "Route 53 secondary calculated health-check query failed"
  fi
else
  warn "Route 53 secondary calculated health-check ID not populated"
fi

printf '\nResult: '
if (( fail == 0 )); then
  printf 'READINESS CHECKS PASSED (read-only evidence only)\n'
else
  printf 'NOT READY — one or more required checks failed\n'
fi

exit "$fail"
