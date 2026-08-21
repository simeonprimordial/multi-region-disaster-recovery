# Disaster-Recovery Runbooks

Twelve production-oriented runbooks covering the major failure modes for a multi-Region payment platform.

Each runbook follows a consistent structure:

1. **Trigger / detection** — signals that start the procedure  
2. **Decision tree** — when to declare disaster vs. local remediation  
3. **Financial-safety gates** — fence old-primary writes, bound replication exposure, promote, verify, synthetic payment + idempotency replay  
4. **Execution steps** — ordered, time-boxed actions  
5. **Verification** — DRServeReady criteria before DNS exposure  
6. **Failback / cleanup** — return to steady state  
7. **Evidence capture** — what to record for post-incident review  

## Catalogue

| ID | Scenario | Primary concern |
|----|----------|-----------------|
| RB-01 | Complete primary Region failure | Full regional outage |
| RB-02 | Database corruption | Logical data integrity |
| RB-03 | DNS poisoning / DNS infrastructure failure | Traffic steering integrity |
| RB-04 | Kafka / MSK cluster failure | Event pipeline continuity |
| RB-05 | Network partition / split-brain | Dual-write authority |
| RB-06 | Cryptographic key compromise | Secrets & TLS trust |
| RB-07 | DDoS attack on payment API | Availability under attack |
| RB-08 | Third-party NPCI / UPI outage | External dependency |
| RB-09 | Certificate expiry / TLS failure | Transport security |
| RB-10 | Single-AZ power failure | AZ-level resilience |
| RB-11 | Ransomware | Integrity & recovery from backup |
| RB-12 | Cascading microservice failure | Application-layer blast radius |

## Financial-Safety Invariant (all runbooks)

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
        → Route 53 may expose standby Region
```

**DNS never creates financial write authority.** Replication alone does not prove business correctness.

Full step-by-step procedures and decision trees exist in the engineering source; this public index captures the catalogue and invariant for portfolio review.
