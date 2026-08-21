# Active-Passive Recovery Budget

## Purpose

Convert top-level recovery objectives (**RPO < 1 minute**, **RTO < 5 minutes**) into engineering budgets for a Mumbai → Hyderabad hot-standby design.

These are **design targets**, not AWS service guarantees. They must be validated through monitoring and DR drills.

## Service criticality model

| Tier | Examples | Why it matters |
|------|----------|----------------|
| **0** — authoritative payment state | Aurora transaction/settlement, DynamoDB idempotency, transaction acceptance | Stale promotion can cause financial inconsistency or duplicates |
| **1** — payment-event continuity | MSK transaction/settlement/webhook/audit events | Lag creates delayed or duplicate downstream work |
| **2** — reconstructable performance state | Redis config/rate-limit/cache | Operationally important; must never be sole payment authority |
| **3** — supporting artefacts | S3 reports, deployment artefacts | Recoverable and India-resident; not on critical path for payment acceptance |

## Component RPO budgets

| Component | Engineering RPO | Failover rule |
|-----------|----------------:|---------------|
| Aurora PostgreSQL | ≤ 30 s | No DR writes until promotion + integrity check succeed |
| DynamoDB | ≤ 15 s | Payment path blocked if idempotency probe unhealthy |
| Amazon MSK | ≤ 30 s | Settlement/event consumers gated until topics healthy |
| Redis | ≤ 60 s (rebuildable) | Degraded mode only if app design proven safe without Redis |
| S3 (DR-scope) | Monitored separately | Must not block transaction acceptance |

## End-to-end RTO target

Hard objective: **< 300 s**. Engineering critical path: **≤ 240 s** (60 s headroom).

| Phase | Target | Cumulative |
|-------|-------:|-----------:|
| Detect regional/application failure | 30 s | 30 s |
| Corroborate signals and declare/fence | 20 s | 50 s |
| Validate replication safety | 20 s | 70 s |
| Promote/activate required data services | 70 s | 140 s |
| Scale/verify critical Hyderabad workloads | 40 s | 180 s |
| Synthetic payment + idempotency verification | 20 s | 200 s |
| Route 53 traffic decision + initial convergence | 30 s | 230 s |
| Confirm live payment success and stabilise | 10 s | **240 s** |

## Design assumptions (to be validated in drills)

- Hyderabad keeps ~**50%** warm worker baseline (e.g. 12 vs 24 Mumbai workers).
- Critical payment-path deployments maintain minimum standby replicas.
- Cluster autoscaling expands toward full failover capacity.
- High-risk windows may pre-scale Hyderabad beyond the normal warm baseline.

## Synthetic verification gate

Traffic is **not** switched on infrastructure `Ready` alone. Minimum checks:

1. HTTPS reaches Hyderabad application path  
2. Payment API accepts a controlled synthetic request  
3. Processor can access the promoted database  
4. Idempotency key write/read works  
5. Repeated synthetic request is **not** processed twice  
6. Required Kafka event is produced/observable  
7. Latency and error status inside temporary DR acceptance threshold  

Only then may `DRServeReady = 1` and DNS expose the standby.

## Headroom policy

- Planned critical path ≤ 240 s  
- Hard recovery objective < 300 s  
- Design headroom ≥ 60 s  

A design that averages 299 s in testing is not acceptable. Phases that repeatedly consume their full budget generate remediation items.

## Evidence required per drill

Incident start · detection · declaration · Tier 0/1 lag · promotion timings · K8s readiness · synthetic result · DNS shift · first successful payment · measured RPO/RTO · exceptions and corrective actions.

Without this evidence, RPO/RTO remain design objectives, not demonstrated outcomes.
