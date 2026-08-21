# Documentation Index

Navigation for the multi-Region disaster-recovery architecture.

## 01 — Current-State Architecture

**Directory:** `docs/01-current-state/`

Single-Region Mumbai baseline, data flows, failure-domain analysis, and assumptions where source detail was incomplete.

## 02 — Multi-Region Architecture Design

**Directory:** `docs/02-multi-region-design/`

- Active-Passive hot-standby design (selected)
- Active-Active alternative
- Comparison matrix and recovery budget
- AWS service behaviour notes

**Decision:** Active-Passive Hot Standby (Mumbai primary / Hyderabad standby).

## 03 — Data Replication Strategy

**Directory:** `docs/03-data-replication/`

Component-specific strategies and sequence diagrams for:

- Aurora PostgreSQL (Global Database)
- DynamoDB (Global Tables)
- ElastiCache Redis (Global Datastore)
- Amazon MSK / Kafka (Replicator)
- Amazon S3

Distinguishes availability replication from financial/business correctness and reconciliation.

## 04 — DNS Failover

**Directory:** `docs/04-dns-failover/`

Route 53 failover design, health checks, timing model, and configuration. DNS exposes traffic; it does **not** create financial write authority.

## 05 — Disaster-Recovery Runbooks

**Directory:** `docs/05-runbooks/`

Twelve runbooks with decision trees:

1. Complete primary Region failure  
2. Database corruption  
3. DNS poisoning / DNS infrastructure failure  
4. Kafka / MSK failure  
5. Network partition / split-brain  
6. Cryptographic key compromise  
7. DDoS attack  
8. NPCI / UPI outage  
9. Certificate expiry / TLS failure  
10. Single-AZ power failure  
11. Ransomware  
12. Cascading microservice failure  

## 06 — Cost Analysis and ROI

**Directory:** `docs/06-cost-analysis/`

Cost model and ROI scenario analysis for Cold / Warm / Hot / Active-Active tiers. Assessment-calibrated; not invoice-level AWS pricing.

## 07 — Data Sovereignty and Compliance

**Directory:** `docs/07-data-sovereignty/`

Compliance matrix and data-flow diagrams. Architecture/compliance mapping only — not regulator or PCI certification.

## 08 — Annual DR Drill Programme

**Directory:** `docs/08-dr-drill-plan/`

Annual drill plan, success criteria, and post-drill template. Defines how achieved RTO/RPO will be measured from real timestamps.

---

## Infrastructure Configuration

| Path | Contents |
|------|----------|
| `configs/terraform/` | Multi-Region root + modules |
| `configs/kubernetes/` | Critical-path workloads, NetworkPolicies, probes, HPA/PDB |
| `configs/monitoring/` | Prometheus rules + DR readiness dashboard requirements |
| `scripts/` | Read-only failover preflight, health checks, drill evidence capture |

## Evidence Boundary

Documentation and static structure are complete. Timed RTO/RPO drills, live AWS deployment evidence, and external audit/regulatory approval are **not** claimed from this repository alone.
