# Architecture Overview — Multi-Region Disaster Recovery

## Selected pattern

**Active-Passive Hot Standby**

| Role | Region | Purpose |
|------|--------|---------|
| Primary | Mumbai `ap-south-1` | Authoritative payment write path |
| Standby | Hyderabad `ap-south-2` | Continuously testable hot standby |

## High-level topology

```text
Customers / Merchants / Banks
              |
           Route 53
          failover DNS
         /            \
        /              \
   Mumbai PRIMARY      Hyderabad DR
   (writes)            (reads + warm capacity)
        |                      |
   Aurora Global  ─────────────┤
   DynamoDB Global Tables ─────┤
   Redis Global Datastore ─────┤
   MSK Replicator ─────────────┘
```

## Core invariants

1. **Exactly one Region holds financial write authority** at any time.  
2. **DNS is traffic exposure**, not the creator of write authority.  
3. **`DRServeReady = 1`** only after fencing, promotion, verification, and synthetic payment + same-idempotency-key replay.  
4. **Domestic payment state stays in India** (Mumbai + Hyderabad).  
5. **RPO < 1 min / RTO < 5 min** are engineering targets validated by drills, not claimed from design alone.

## Control plane summary

| Layer | Primary capability |
|-------|--------------------|
| Compute | EKS (warm secondary workers, topology-aware scheduling) |
| Data | Aurora Global, DynamoDB Global Tables, Redis Global Datastore, MSK Replicator |
| Traffic | Route 53 failover + calculated health checks gated on DRServeReady |
| Security | PSS restricted, NetworkPolicies, Pod Identity, WAF, multi-Region KMS |
| Observability | Independent regional metrics, lag alarms, synthetic payments |
| Operations | 12 scenario runbooks, annual drill programme, preflight/readiness scripts |

## Repository map

| Path | Contents |
|------|----------|
| `configs/terraform/` | Multi-region IaC skeleton (networking, EKS, data, DNS) |
| `configs/kubernetes/` | Hardened payment workloads, policies, ingress |
| `configs/monitoring/` | Prometheus rules for success rate, latency, lag |
| `docs/` | Design comparisons, recovery budget, DNS, cost/ROI, sovereignty, drills |
| `scripts/` | Failover preflight and DR readiness checks |
