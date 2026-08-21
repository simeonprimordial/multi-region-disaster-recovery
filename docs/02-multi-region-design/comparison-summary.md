# Active-Passive vs Active-Active — Decision Summary

## Recommendation: **Active-Passive Hot Standby**

Mumbai (`ap-south-1`) primary · Hyderabad (`ap-south-2`) hot standby.

| Criterion | Weight | Active-Passive | Active-Active |
|-----------|-------:|---------------:|--------------:|
| RTO | 15% | 4 | 5 |
| RPO | 15% | 4 | 4 |
| Cost | 15% | 4 | 2 |
| Financial correctness | 20% | 5 | 3 |
| Complexity | 10% | 4 | 2 |
| Latency impact | 5% | 5 | 4 |
| Operational burden | 10% | 4 | 2 |
| Audit simplicity | 5% | 5 | 3 |
| Failover readiness | 3% | 4 | 5 |
| Failback simplicity | 2% | 4 | 2 |
| **Weighted total** | **100%** | **4.30 / 5** | **3.19 / 5** |

## Key numbers

| | Active-Passive | Active-Active |
|--|---------------:|--------------:|
| Engineering full RTO target | ~240 s | ~180 s |
| Approx. annual infra (mid) | ~₹11.6–12.6 cr | ~₹15–16 cr |
| Serving payment Regions | 1 | 2 |
| Aurora write authority | 1 primary | 2 shard primaries |
| MSK replication directions | 1 | 2 |

## Why Active-Passive wins for this platform

1. Meets sub-5-minute RTO target on the planned critical path with headroom  
2. Single financial write authority — lower split-brain and duplicate-payment risk  
3. Lower cost (~₹4+ crore/year midpoint difference)  
4. Operational fit for an ~8-person platform team  
5. Simpler compliance/audit narrative (India-resident primary + controlled promotion)  
6. Baseline P99 latency remains local to Mumbai under normal conditions  

Active-Active remains a documented future option if volume, downtime economics, and team maturity justify dual-writer complexity.

Full matrix and recovery budgets live alongside this summary in the private engineering notes; this file is the portfolio decision snapshot.
