# Cost Summary — Multi-Region Disaster Recovery

## Purpose

Compare four disaster-recovery tiers against a single-Region baseline for a payment platform that must meet **RPO < 1 minute**, **RTO < 5 minutes**, and **99.99% availability**. A cheap tier that cannot meet the recovery objective is not acceptable for Tier-0 payments.

**Baseline annual infrastructure spend (fictional):** ₹8.00 crore  
**Selected architecture:** Active-Passive Hot Standby (Mumbai primary / Hyderabad standby)

## Four-Tier Results

| DR Tier | Annual Cost (unoptimized) | Multiplier | Optimized | Fit |
|---------|--------------------------:|-----------:|----------:|-----|
| Current / no regional DR | ₹8.00 cr | 1.00× | — | Baseline |
| Cold Standby | ₹8.57 cr | 1.07× | ₹8.55 cr | Too slow for <5 min RTO |
| Warm Standby | ₹11.33 cr | 1.42× | ₹11.10 cr | Attractive cost; RTO typically 15–60 min |
| **Hot Standby (selected)** | **₹13.00 cr** | **1.63×** | **₹12.62 cr** | **Meets RTO/RPO engineering model** |
| Active-Active | ₹15.73 cr | 1.97× | ₹15.06 cr | Best recovery speed; higher cost & complexity |

## Major Cost Drivers (Hot Standby)

- Live EKS cluster + warm worker fleet in Hyderabad  
- Aurora Global Database secondary capacity  
- DynamoDB Global Table replication  
- Redis Global Datastore capacity  
- DR MSK cluster + Replicator  
- Independent observability, security parity (KMS, WAF, CDE segmentation)  
- Cross-Region replication / data-transfer traffic  
- Operational readiness (runbooks, drills, on-call training)

Route 53 and health checks are not the dominant cost; the services that must already exist before failure are.

## Recommendation

**Active-Passive Hot Standby** remains the recommended implementation.

- Cold is too slow.  
- Warm fails the <5-minute payment recovery objective.  
- Active-Active delivers excellent recovery characteristics but the incremental cost and dual-writer complexity are not justified for an ~8-person platform team under the base-case risk model.  
- Hot Standby occupies the best feasible point on the cost/resilience curve while preserving a single financial write authority.

The model is scenario-calibrated. Exact AWS Price List reconciliation requires production sizing data (instance classes, storage, I/O, transfer GB, etc.) that becomes available once test workloads exist.
