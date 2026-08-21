# Documentation Index — Multi-Region Disaster Recovery

Navigation entry point for the multi-Region DR architecture of a fictional Indian payment aggregator platform.

## 01 — Current-State Architecture

**Directory:** `docs/01-current-state/`

Single-Region Mumbai baseline, data flows, failure-domain analysis, and assumptions where source detail was incomplete. Architecture diagram (source + PNG).

## 02 — Multi-Region Architecture Design

**Directory:** `docs/02-multi-region-design/`

- Active-Passive Hot Standby design (selected)
- Active-Active alternative design
- `comparison-summary.md` — quantified option comparison and recommendation
- Recovery-budget and AWS service-validation notes

**Decision:** Active-Passive Hot Standby selected (weighted score 4.30 / 5 vs 3.19 / 5).

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

Route 53 failover design, health checks, timing model and configuration. DNS is treated as a traffic-exposure mechanism; it does **not** create financial write authority.

## 05 — Disaster-Recovery Runbooks

**Directory:** `docs/05-runbooks/`

Twelve production-oriented runbooks with decision trees:

1. Complete primary Region failure  
2. Database corruption  
3. DNS poisoning / DNS infrastructure failure  
4. Kafka / MSK failure  
5. Network partition / split-brain  
6. Cryptographic key compromise  
7. DDoS attack on payment API  
8. Third-party NPCI / UPI outage  
9. Certificate expiry / TLS failure  
10. Single-AZ power failure  
11. Ransomware  
12. Cascading microservice failure  

## 06 — Cost Analysis and ROI

**Directory:** `docs/06-cost-analysis/`

Scenario cost model and ROI analysis for Cold / Warm / Hot / Active-Active tiers. Selected Hot Standby ≈ ₹12.6 cr/year optimized. Assessment-calibrated; not invoice-level AWS pricing.

## 07 — Data Sovereignty and Compliance

**Directory:** `docs/07-data-sovereignty/`

Compliance matrix and data-flow diagrams. Topology keeps domestic payment-system state and mandatory security evidence inside India (Mumbai + Hyderabad). Mapping only — not regulatory certification.

## 08 — Annual DR Drill Programme

**Directory:** `docs/08-dr-drill-plan/`

Annual drill plan, success criteria and post-drill template. Defines how achieved RTO/RPO will be measured from real timestamps.

---

## Infrastructure & Operational Configuration

| Area | Location |
|------|----------|
| Terraform multi-Region modules | `configs/terraform/` |
| Kubernetes critical-path workloads | `configs/kubernetes/` |
| Monitoring / Prometheus rules | `configs/monitoring/` |
| Failover preflight (read-only) | `scripts/failover/` |
| DR readiness & inventory | `scripts/health-checks/` |
| Drill evidence capture | `scripts/dr-drill/` |

Operational scripts are intentionally **read-only**. No committed script can promote databases, rewrite customer DNS or bypass financial-authority gates.

## Evidence Boundary

| Claim | Status |
|-------|--------|
| Architecture design + comparison | Documented |
| Component replication strategies | Documented |
| DNS failover design | Documented |
| 12 runbooks + decision trees | Complete (source) |
| Cost / ROI model | Scenario model |
| Data-sovereignty mapping | Design mapping |
| Terraform / Kubernetes static structure | Present |
| Timed RTO/RPO drill evidence | Not claimed |
| Live AWS deployment evidence | Not claimed |
| Regulatory / PCI certification | Not claimed |

**Correct claim:** documented, designed and statically structured multi-Region DR architecture — not a production-proven deployed platform.
