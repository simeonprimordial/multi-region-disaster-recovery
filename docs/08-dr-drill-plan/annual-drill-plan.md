# Annual Disaster Recovery Drill Plan

## Objectives under test

| Metric | Hard objective | Engineering target |
|--------|----------------|-------------------|
| RTO | < 300 s | ≤ 240 s |
| Financial RPO | < 60 s | Aurora ≤30s · DDB ≤15s · MSK ≤30s · Redis ≤60s |
| Topology | Active-Passive Hot Standby | Mumbai primary · Hyderabad standby |

## Purpose

Convert architecture, runbooks and recovery budgets into a twelve-month verification programme that answers:

1. Can Hyderabad take over the payment workload inside the RTO?  
2. Is data safe enough to accept new financial writes inside the RPO?  
3. Can people execute recovery without undocumented knowledge?  
4. Can the organisation prove what happened to management, auditors, regulators and partners?

**Design is not proof.** Terraform present ≠ recoverability. Aurora secondary `available` ≠ transaction correctness. Route 53 healthy ≠ end-to-end payment path after failover.

## Exercise levels

| Level | Meaning |
|-------|---------|
| 1 — Tabletop | No infrastructure mutation; decision and communication walk-through |
| 2 — Test / pre-prod | Real AWS commands against representative non-production |
| 3 — Production component | Bounded reversible production change (local Aurora failover, zonal drain, cert rollover) |
| 4 — Controlled regional switchover | Full Mumbai → Hyderabad path under executive-approved conditions |

## Annual calendar (operating plan)

| Month | Exercise | Level | Focus |
|-------|----------|------:|-------|
| Jan | Readiness baseline + inventory | 2 | Resource IDs, DR_READY dashboard, quotas |
| Feb | Data-layer recovery | 2 | RB-02, Aurora/DynamoDB/S3 PITR, RPO measurement |
| Mar | Q1 tabletop: partition + Mumbai degradation | 1 | RB-05 → RB-01 branch |
| Apr | Messaging/cache continuity | 2 | RB-04, MSK, Redis |
| May | Single-AZ + EKS capacity | 3 | RB-10 |
| **Jun** | **H1 full planned regional switchover** | **4** | **RB-01 + DNS + all stateful services** |
| Jul | Cyber recovery + key exercise | 1/2 | RB-06, RB-11 |
| Aug | External dependency + DDoS | 1/2 | RB-07, RB-08 |
| Sep | TLS / DNS resilience | 2/3 | RB-03, RB-09 |
| Oct | Cascading-service chaos | 2 | RB-12 |
| Nov | Unannounced Arena simulation | 2 | Random 3 of RB-01…RB-12 |
| Dec | Annual governance review | 1 | Trends, remediation, capacity plan |

## Monthly readiness (always)

Hyderabad EKS ACTIVE · warm node baseline · Aurora lag · DynamoDB synthetic idempotency · Redis state · MSK Replicator · Route 53 health checks · `DRServeReady=0` in normal standby · certs/KMS · India-resident logs · quotas · escalation contacts · prior critical remediations closed.

Failed item → DR dashboard **DEGRADED** → no five-minute recovery claim until fixed.

## June full switchover — success gate

Passes only if measured:

- RTO < 300 s (engineering target ≤ 240 s)  
- No Tier-0 financial RPO exposure > 60 s  
- Aurora lag at decision ≤ 30 s (or formally escalated before writes)  
- Synthetic duplicate replay → exactly one transaction  
- No split-brain period  
- Critical payment path succeeds from external probes  
- Kafka/settlement/audit path accounted for  
- Failback completes via documented controlled sequence  

Miss 300 s RTO or create ambiguous dual writes → **DR NOT PROVEN** until a repeat test passes.

## RTO measurement timestamps

```text
T0 = fault / exercise injection
T1 = first valid detection
T2 = P1 declaration / fencing starts
T3 = replication exposure accepted
T4 = stateful activation complete
T5 = Hyderabad EKS ready
T6 = synthetic payment + duplicate replay pass
T7 = DNS/traffic exposure starts
T8 = first successful externally observed Hyderabad payment

Customer RTO = T8 − T0
```

## Central principle

> **No drill evidence, no DR claim.**

This repository documents procedures and success gates. Timed evidence requires executed drills against bound test resources.
