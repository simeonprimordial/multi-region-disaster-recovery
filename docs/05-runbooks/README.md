# DR Runbooks Catalogue

Twelve production-oriented disaster-recovery scenarios for an Active-Passive Hot Standby payment platform (Mumbai primary · Hyderabad standby).

| ID | Scenario | Decision tree |
|----|----------|---------------|
| **RB-01** | Complete primary Region failure | [RB-01-decision-tree.md](./RB-01-decision-tree.md) |
| **RB-02** | Database corruption | [RB-02-decision-tree.md](./RB-02-decision-tree.md) |
| **RB-03** | DNS poisoning / DNS infrastructure failure | — |
| **RB-04** | Kafka / MSK cluster failure | — |
| **RB-05** | Network partition / split-brain prevention | [RB-05-decision-tree.md](./RB-05-decision-tree.md) |
| **RB-06** | Cryptographic key compromise | — |
| **RB-07** | DDoS on payment API | — |
| **RB-08** | Third-party NPCI / UPI outage | — |
| **RB-09** | Certificate expiry / TLS failure | — |
| **RB-10** | Single-AZ power failure | [RB-10-decision-tree.md](./RB-10-decision-tree.md) |
| **RB-11** | Ransomware | — |
| **RB-12** | Cascading microservice failure | — |

## Shared rules across all runbooks

1. **Exactly one Region holds financial write authority** at any time.  
2. **DNS never creates write authority** — only exposes a Region after `DRServeReady = 1`.  
3. **Synthetic payment + same-idempotency-key replay** must pass before customer traffic is steered to the standby.  
4. **No automatic failback** when the old primary recovers; planned switchover only after reconciliation.  
5. **Stop for safety** if dual-write, unreconcilable corruption, or uncontrolled exposure is detected.

Full procedure bodies (commands, roles, timings, communication templates) are environment-specific and are not published in this public portfolio version. Decision trees capture the branching logic that keeps financial safety intact.
