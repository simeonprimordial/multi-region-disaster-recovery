# RB-04 Decision Tree — Kafka / Amazon MSK Cluster Failure

```mermaid
flowchart TD
    A[Kafka producer/consumer failure alert] --> B{Broad Mumbai outage?}
    B -->|Yes| B1[Execute RB-01 Region Failure]
    B -->|No| C{Only cross-region replication/link impaired?}
    C -->|Yes| C1[Execute RB-05 Network Partition]
    C -->|No| D[Inspect source MSK cluster + partition health]

    D --> E{Source MSK healing quickly and customer impact tolerable?}
    E -->|Yes| E1[Observe managed recovery\nDo not force cross-region cutover]
    E -->|No| F{Hyderabad MSK ACTIVE + target topics healthy?}

    F -->|No| F1{Can payments safely commit without Kafka?}
    F1 -->|Yes| F2[Controlled degraded mode\nPersist authoritative state in Aurora]
    F1 -->|No| F3[Fail closed / broader DR decision]

    F -->|Yes| G{Last replication/offset exposure bounded?}
    G -->|No| G1[Pause financial consumers\nBound event gap from Aurora + metrics]
    G -->|Yes| H{Payment commit safe without source Kafka?}
    G1 --> H

    H -->|Yes| H1[Continue payments in tested degraded mode while switching]
    H -->|No| H2[Pause new payments until DR producer path verified]

    H1 --> I[Stop source consumers]
    H2 --> I
    I --> J[Switch producer bootstrap to Hyderabad MSK]
    J --> K{Synthetic event/payment reaches target?}
    K -->|No| K1[Rollback config / fail closed]
    K -->|Yes| L[Start one instance of each consumer]

    L --> M{Duplicate/order errors appear?}
    M -->|Yes| M1[Stop consumers\nPreserve offsets\nResolve idempotency]
    M -->|No| N[Reconcile Aurora-to-Kafka event gap]

    N --> O{Replay count + downstream effects reconcile?}
    O -->|No| O1[Keep exception list\nDo not claim full recovery]
    O -->|Yes| P[Scale target consumers]

    P --> Q[Monitor lag drains]
    Q --> R{Mumbai MSK recovers?}
    R -->|No| R1[Operate on Hyderabad\nMaintain DR evidence]
    R -->|Yes| S[Create/verify reverse replication\nPlanned failback only]
```

## Quantified branch criteria

| Decision | Safe continuation | Stop / alternate branch |
|----------|-------------------|-------------------------|
| Failure scope | EKS/Aurora/ALB healthy; MSK-specific | Broad Region failure → RB-01 |
| Replication-only fault | Source MSK serves locally | Cross-region link only → RB-05 |
| Target cluster | Hyderabad `ACTIVE`, critical topics healthy | Target unhealthy → degraded/fail-closed |
| Replication exposure | Critical lag ≤30 s or bounded exception | Unknown exposure → pause financial consumers |
| Payment degraded mode | Authoritative Aurora commit independent of Kafka | Kafka required for safe commit → fail closed |
| Consumer recovery | No uncontrolled duplicate downstream action | Duplicate settlement → stop consumers |
| Failback | Reverse replication caught up; planned switch | Never auto-return to recovered source |
