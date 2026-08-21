# DR Drill Success Criteria

## Purpose

Objective pass/fail criteria for every disaster-recovery exercise. An exercise is not successful merely because responders finished a runbook or AWS resources became healthy.

| Result | Meaning |
|--------|---------|
| **PASS** | Every mandatory criterion for the exercise scope is satisfied |
| **PASS WITH FINDINGS** | Hard RTO/RPO and safety criteria pass; engineering targets or non-critical controls need remediation |
| **FAIL** | A hard recovery, data-integrity, authority, verification or safety criterion is missed |
| **STOPPED FOR SAFETY** | Controller invoked a stop condition; evaluate from evidence |

## Global Mandatory Criteria

| ID | Criterion | PASS | FAIL |
|----|-----------|------|------|
| G-01 | Financial write authority | Exactly one authorised payment-writing Region | Overlapping / unknown dual-write authority |
| G-02 | Idempotency | Same synthetic payment key → exactly one financial action | Duplicate or uncertain result |
| G-03 | Transaction integrity | No unexplained committed-payment loss/corruption | Unreconciled authoritative discrepancy |
| G-04 | Hard RTO | First successful recovered payment < 300 s from fault | ≥ 300 s without approved exclusion |
| G-05 | Financial RPO | Authoritative data-loss exposure < 60 s | ≥ 60 s accepted without escalation |
| G-06 | External verification | Synthetic end-to-end payment succeeds on public/service path | Only infrastructure health checks pass |
| G-07 | Rollback / failback | Safe documented path back to stable topology | Cannot safely return |
| G-08 | Evidence | UTC timestamps and decision evidence sufficient to recompute RTO/RPO | Timings depend on memory/estimate |
| G-09 | Security | No uncontrolled credentials/data exposure | Sensitive data or keys exposed |
| G-10 | Communications | Required audiences receive correct messages within targets | Critical audience omitted or misled |

## Engineering Recovery Budget (full regional)

| Phase | Target |
|-------|-------:|
| Detect failure | 30 s |
| Corroborate / declare / fence | 20 s |
| Validate replication exposure | 20 s |
| Activate stateful services | 70 s |
| EKS scale / readiness | 40 s |
| Synthetic payment + replay | 20 s |
| DNS transition budget | 30 s |
| Final confirmation | 10 s |
| **Total engineering target** | **≤ 240 s** |

241–299 s = PASS WITH FINDINGS · ≥ 300 s = FAIL

## Component Gates

| Component | Target / rule |
|-----------|---------------|
| Aurora | Lag ≤ 30 s; writer confirmed before application writes |
| DynamoDB | Convergence ≤ 15 s; duplicate-replay test passes |
| MSK | Lag ≤ 30 s; duplicate-safe processing demonstrated |
| Redis | Recovery state ≤ 60 s; never authoritative for payments |
| DNS | `DRServeReady=1` only after authority + synthetic verification |

**Any uncontrolled split-brain = FAIL.**

## Evidence Completeness

Score 0–2 on ten dimensions (detection, decision, command trace, RPO, RTO, business-path verification, idempotency/reconciliation, communications, rollback, remediation ownership).

- **≥ 18/20** → PASS  
- **15–17** → PASS WITH FINDINGS (only if no hard safety/RTO/RPO failure)  
- **< 15** → FAIL for insufficient evidence  

Timed RTO/RPO and production-proven status require actual drill evidence; design documents alone do not constitute proof.
