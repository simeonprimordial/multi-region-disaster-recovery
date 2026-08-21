# ROI Summary — Multi-Region Disaster Recovery

## Question

- **Cost model:** What does each DR architecture cost?  
- **ROI model:** How much annual business risk does each architecture remove, and is that worth the incremental recurring cost?

ROI is **not** the only criterion. Mandatory objectives are **RTO < 5 minutes** and **RPO < 1 minute**. A cheaper tier with high ROI still fails if it cannot meet those objectives for the Tier-0 payment path.

## Illustrative inputs (scenario-calibrated)

| Input | Value |
|-------|------:|
| Current annual infra spend | ₹8.00 cr |
| Current annual downtime | ~7 hours |
| Direct revenue loss | ~₹37.5 lakh/hour |
| Regulatory fine range (major P1) | ₹50 lakh – ₹2 cr |
| Recovery labour (current) | 500+ eng-hours @ ~₹3,000/hour |

Base-case expected current-state P1 loss ≈ **₹5.29 cr** (direct + SLA + expected fine + reputation + recovery labour).

## Base-case comparison

| Tier | Optimized annual cost | Expected P1 loss | Incremental DR cost | Net annual benefit | ROI | Meets <5m RTO? |
|------|----------------------:|-----------------:|--------------------:|-------------------:|----:|----------------|
| Current | ₹8.00 cr | ₹5.29 cr | — | — | — | No |
| Cold | ₹8.55 cr | ₹5.53 cr | ₹0.55 cr | −₹0.79 cr | −142% | No |
| Warm | ₹11.10 cr | ₹1.20 cr | ₹3.10 cr | ₹0.99 cr | **32%** | No |
| **Hot (selected)** | **₹12.62 cr** | **₹0.31 cr** | **₹4.62 cr** | **₹0.36 cr** | **7.9%** | **Yes** |
| Active-Active | ₹15.06 cr | ₹0.15 cr | ₹7.06 cr | −₹1.92 cr | −27% | Yes |

## Interpretation

- **Cold** — Reject (fails RTO/RPO; negative ROI).  
- **Warm** — Strong pure financial ROI but fails mandatory RTO → reject for Tier-0 payments.  
- **Hot Standby** — Modest positive ROI **and** meets recovery objectives; single financial write authority. **Select.**  
- **Active-Active** — Best technical recovery; negative base-case ROI and dual-writer complexity → future evolution, not current recommendation.

Resilience investments behave partly like insurance: benefit concentrates in infrequent high-impact events. Exact ROI percentage should not be treated as a guaranteed return; assumptions must be stress-tested.

## Recommendation

> Implement **Active-Passive Hot Standby**, then optimise predictable incremental compute/database/cache capacity with appropriate commitments after measuring the steady-state DR footprint.
