# RB-10 Decision Tree — Single-AZ Power Failure

```mermaid
flowchart TD
 A[AZ failure signals] --> B{Exactly one AZ affected?}
 B -->|No| C[Escalate to RB-01 regional/compound failure]
 B -->|Yes| D{EKS control plane ACTIVE?}
 D -->|No| C
 D -->|Yes| E[Allow reschedule + scale in surviving AZs]
 E --> F{Critical pods schedulable?}
 F -->|No| G[Add surviving-zone capacity / approved temporary topology relaxation]
 F -->|Yes| H{Aurora writer healthy?}
 G --> H
 H -->|No| I[Wait for/force local Aurora cluster failover]
 H -->|Yes| J{Kafka offline partitions?}
 I --> J
 J -->|Yes| K[Invoke RB-04 Kafka recovery]
 J -->|No| L{Payment success >=99% for 5m?}
 K --> L
 L -->|Yes| M{Surviving capacity <80% and no second-AZ degradation?}
 L -->|No| N[Continue in-region recovery]
 M -->|Yes| O[Remain Mumbai primary]
 M -->|No| P[Invoke RB-01 if capacity/second AZ unsafe]
 N --> Q{Payment <95% for 2m after recovery attempts?}
 Q -->|No| N
 Q -->|Yes| P
 P --> R[Hyderabad only after replication/authority/DRServeReady gates]
```

## Branch rules

1. A single-AZ failure is contained in Mumbai whenever two healthy AZs can safely sustain payment traffic.
2. EKS control-plane availability does not prove worker/pod capacity; both are checked.
3. Aurora normally handles local writer failure automatically; manual failover is a fallback, not the first action.
4. Offline MSK brokers alone do not imply Kafka outage — offline partitions, client failover and replication health decide whether RB-04 is needed.
5. Cross-Region DR is triggered by measured service/capacity failure or compound AZ degradation, not the mere existence of one unavailable AZ.
6. A recovered AZ is reintroduced by controlled canary, never by immediately repacking all workloads into it.
