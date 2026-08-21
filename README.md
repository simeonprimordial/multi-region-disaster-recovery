# Multi-Region Disaster Recovery — Payment Platform

> Production-oriented multi-Region disaster-recovery architecture for a payment aggregator platform (PaySecure Gateway).

## Objective

Design a resilient multi-Region DR architecture for a fictional Indian payment aggregator whose production platform is concentrated in AWS Mumbai (`ap-south-1`), with a hot-standby Region in Hyderabad (`ap-south-2`).

### Targets

| Metric | Objective |
|--------|-----------|
| Availability | **99.99%** |
| RPO | **< 1 minute** |
| RTO | **< 5 minutes** |
| DR topology | Multi-Region **inside India** (data sovereignty) |

### Platform baseline (fictional)

| Parameter | Value |
|-----------|------:|
| Daily transaction volume | ~3.2 million |
| Daily transaction value | ~₹500 crore |
| Peak TPS | ~1,200 |
| P99 latency | 180 ms |
| Active merchants | ~45,000 |
| Primary Region | `ap-south-1` (Mumbai) |
| DR Region | `ap-south-2` (Hyderabad) |
| Platform team size | 8 engineers |

---

## Selected Architecture: Active-Passive Hot Standby

```text
Customers / Merchants / Banks
            |
         Route 53
        failover DNS
        /          \
       /            \
Mumbai PRIMARY      Hyderabad DR
ap-south-1          ap-south-2
10.20.0.0/16        10.30.0.0/16
     |                    |
 WAF / ALB             WAF / ALB
     |                    |
 EKS active            EKS warm
 24 workers            12 warm workers
     |                    |
     +---- cross-Region replication ----+
     |                                   |
Aurora Global DB                 DynamoDB Global Table
Redis Global Datastore           MSK Replicator
```

### Why Active-Passive (not Active-Active)

| Configuration | Weighted score | Approx. annual infra |
|---|---:|---:|
| **Active-Passive Hot Standby** | **4.30 / 5** | **₹12.6 crore** (optimized) |
| Active-Active | 3.19 / 5 | ₹15.1 crore |

Active-Passive wins on:

- Single financial write-authority model (lower split-brain risk)
- Lower cost and operational burden for an 8-person platform team
- Ability to target the RTO/RPO window with a simpler control plane

Both designs are fully documented under `docs/02-multi-region-design/`.

### Engineering recovery gates

| Gate | Target |
|------|--------|
| End-to-end recovery critical path | ≤ 240 s |
| Hard RTO | < 300 s |
| Financial RPO | < 60 s |
| Aurora lag | ≤ 30 s |
| DynamoDB convergence | ≤ 15 s |
| MSK replication lag | ≤ 30 s |
| Redis recovery state | ≤ 60 s |

These are **engineering objectives**. They become proven only after timed drills.

---

## Financial-Safety Invariant

Service health ≠ payment authority.

```text
regional failure detected
        → corroborate incident
        → fence old-primary writes
        → bound replication exposure
        → promote required state
        → verify DR workloads
        → synthetic payment + idempotency replay
        → DRServeReady = 1
        → Route 53 may expose Hyderabad
```

**DNS never creates financial write authority.** Replication alone does not prove business correctness. Ambiguous transactions are reconciled using authoritative payment references and idempotency keys.

---

## Data Sovereignty

Domestic payment-system state and mandatory security evidence stay in India:

- Mumbai — primary payment/data Region  
- Hyderabad — hot-standby / DR Region  
- No normal cross-border replica for Aurora payment records, DynamoDB idempotency, Redis payment-derived state, MSK payment events, or CDE/security logs  

Compliance mapping is architecture design — not regulatory certification.

---

## Repository Contents

```text
multi-region-disaster-recovery/
├── README.md
├── docs/
│   ├── 01-current-state/          # Single-Region baseline analysis
│   ├── 02-multi-region-design/    # Active-Passive + Active-Active + comparison
│   ├── 03-data-replication/       # Aurora, DynamoDB, Redis, MSK, S3 strategies
│   ├── 04-dns-failover/           # Route 53, health checks, timing
│   ├── 05-runbooks/               # 12 production DR runbooks + decision trees
│   ├── 06-cost-analysis/          # Cost model + ROI
│   ├── 07-data-sovereignty/       # Compliance matrix + data flows
│   └── 08-dr-drill-plan/          # Annual drill programme + success criteria
├── configs/
│   ├── terraform/                 # Multi-Region modules (network, EKS, DB, DNS…)
│   ├── kubernetes/               # Critical-path workloads, NetworkPolicies, HPA/PDB
│   └── monitoring/                # Prometheus rules + DR readiness dashboard
├── scripts/
│   ├── failover/                  # Read-only preflight
│   ├── health-checks/             # DR readiness + inventory
│   └── dr-drill/                  # Evidence capture
└── .github/workflows/             # Terraform/K8s validate, diagram export
```

### Twelve DR runbooks

1. Complete primary Region failure  
2. Database corruption  
3. DNS poisoning / DNS infrastructure failure  
4. Kafka / MSK cluster failure  
5. Network partition / split-brain  
6. Cryptographic key compromise  
7. DDoS attack on payment API  
8. Third-party NPCI / UPI outage  
9. Certificate expiry / TLS failure  
10. Single-AZ power failure  
11. Ransomware  
12. Cascading microservice failure  

### Terraform modules

Networking · Compute (EKS) · Database (Aurora Global) · DynamoDB Global Table · Cache (Redis Global Datastore) · Messaging (MSK + Replicator) · DNS (Route 53 failover) · Monitoring · Security (KMS/WAF) · Workload identity

### Kubernetes critical path

- `payment-api` and `transaction-processor` Deployments  
- Startup / readiness / liveness probes  
- HPA + PDB  
- Restricted security contexts  
- Topology spreading  
- Default-deny + critical-path NetworkPolicies  
- ALB Ingress contract  

Operational scripts are **read-only** — none can promote databases, rewrite DNS, or bypass financial-authority gates without human approval.

---

## Evidence Boundaries

| Claim | Status |
|-------|--------|
| Architecture design + comparison | Documented |
| Component replication strategies | Documented |
| DNS failover design | Documented |
| 12 runbooks + decision trees | Complete |
| Cost / ROI model | Scenario model (not invoice-level) |
| Data-sovereignty mapping | Design mapping only |
| Terraform / Kubernetes static validation | CI-ready |
| Timed RTO/RPO drill evidence | Not claimed |
| Live AWS deployment evidence | Not claimed |
| Regulatory / PCI certification | Not claimed |

**Correct claim:** documented, designed and statically structured multi-Region DR architecture — not a production-proven deployed platform.

---

## Author

**SimeonOnTheCloud** ([@simeonprimordial](https://github.com/simeonprimordial))

Building secure, scalable and automated cloud infrastructure with a focus on reliability, operational excellence and continuous improvement.

---

*This public repository is a portfolio version of multi-Region disaster-recovery engineering work.*
