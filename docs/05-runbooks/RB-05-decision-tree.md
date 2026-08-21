# RB-05 Decision Tree — Network Partition / Split-Brain Prevention

```mermaid
flowchart TD
    A[Cross-region replication/connectivity alert] --> B{Mumbai broadly unhealthy?}
    B -->|Yes| B1[Execute RB-01\nOld-writer fencing required]
    B -->|No| C{Both Mumbai + Hyderabad locally healthy?}
    C -->|No| C1[Diagnose regional/component-specific incident]
    C -->|Yes| D[Declare partition\nKeep payment authority = Mumbai\nSet DRServeReady=0]

    D --> E{Only MSK source cluster failed?}
    E -->|Yes| E1[Execute RB-04]
    E -->|No| F[Capture Aurora/DDB/Redis/MSK lag]

    F --> G{Any unauthorized Hyderabad financial writes?}
    G -->|Yes| G1[STOP Hyderabad writers\nPreserve secondary-origin records]
    G -->|No| H{Critical replication exposure >60s?}
    G1 --> I[Reconcile secondary-origin items against Aurora + partner truth]

    H -->|Yes| H1[P1 / RPO breach candidate\nContinue Mumbai if payment path healthy]
    H -->|No| H2[DR degraded P2\nContinue Mumbai]

    I --> J{Financial conflicts all classified?}
    J -->|No| J1[Keep exception set open\nNo authority transfer]
    J -->|Yes| K[Prepare corrected application-level records]

    H1 --> L{Inter-region connectivity restored?}
    H2 --> L
    K --> L

    L -->|No| M{Does Mumbai fail during partition?}
    M -->|No| F
    M -->|Yes| N{Can old Mumbai write authority be fenced?}
    N -->|No| N1[Controlled outage\nDo not promote Hyderabad]
    N -->|Yes| B1

    L -->|Yes| O[Allow native replication catch-up]
    O --> P{Aurora <=30s, DDB <=15s, MSK <=30s, Redis <=60s and stable?}
    P -->|No| O
    P -->|Yes| Q[Verify conflict candidates in both Regions]

    Q --> R{DynamoDB conflict winner matches financial reconciliation?}
    R -->|No| R1[Application-approved idempotency repair\nNew authority epoch + audit]
    R -->|Yes| S[Cross-region synthetic/idempotency validation]
    R1 --> S

    S --> T{Exactly-one financial outcome + no unauthorized secondary writers?}
    T -->|No| T1[Keep DR readiness RED\nContinue remediation]
    T -->|Yes| U[Restore DR readiness GREEN]
```

## Authority rule

A network partition **never automatically transfers authority**. Mumbai remains the only payment writer while both Regions are locally healthy. Hyderabad becomes writer only through an explicit RB-01 authority-transfer sequence after old-primary fencing.

## Quantified branch criteria

| Decision | Normal / continue | Escalate / stop |
|----------|-------------------|-----------------|
| Regional health | Both Regions locally reachable | Mumbai unavailable → RB-01 |
| DR readiness | Lag within targets | Critical exposure >60s → RPO breach candidate |
| Hyderabad writes | None expected in active-passive | Any production payment/idempotency write → split-brain P1 |
| Catch-up | Aurora ≤30s, DDB ≤15s, MSK ≤30s, Redis ≤60s | Keep DR red while above thresholds |
| Compound failure | Mumbai healthy → keep authority | Mumbai fails during partition → fail over only after fencing |
| Financial conflict | Reconciled against Aurora + external reference | Never accept last-writer-wins timestamp as financial truth alone |
