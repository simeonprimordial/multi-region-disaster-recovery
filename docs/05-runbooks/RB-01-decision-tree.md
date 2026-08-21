# RB-01 Decision Tree — Complete Primary Region Failure

Supports the full regional failover procedure. Branching is intentional so responders can evaluate the path without reading the full runbook first.

```mermaid
flowchart TD
    A[Primary payment-path P1 alert] --> B{Only one Mumbai AZ affected?}
    B -->|Yes| B1[Execute RB-10 Single-AZ Failure]
    B -->|No| C{Mumbai reachable from independent external probes?}

    C -->|Yes| D{Only Mumbai-Hyderabad connectivity/replication broken?}
    D -->|Yes| D1[Execute RB-05 Network Partition]
    D -->|No| E[Continue multi-signal diagnosis]
    C -->|No| E

    E --> F{Hyderabad endpoint, EKS and critical deps healthy?}
    F -->|No| F1[Dual-region incident mode\nDo not expose Hyderabad DNS]
    F -->|Yes| G{Tier-0/Tier-1 replication exposure bounded?}

    G -->|No / Unknown| G1[Keep DRServeReady=0\nRisk decision\nNo customer writes]
    G -->|Yes| H{Aurora <=30s, DDB <=15s, MSK <=30s?}

    H -->|No but all <60s| H1[Record exposure\nExplicit approval to continue]
    H -->|Any >60s| H2[RPO breach candidate\nBlock customer-write enablement]
    H -->|Yes| I[Promote Aurora + Redis\nValidate DDB + MSK]
    H1 --> I

    I --> J{Stateful activation successful?}
    J -->|No| J1[DRServeReady=0\nRollback or controlled outage]
    J -->|Yes| K[Scale/verify Hyderabad EKS]

    K --> L{Synthetic payment succeeds?}
    L -->|No| J1
    L -->|Yes| M{Same idempotency key replay creates duplicate?}

    M -->|Yes| M1[STOP\nFinancial safety failure\nDRServeReady=0]
    M -->|No| N[Set DRServeReady=1]

    N --> O[Route 53 makes Hyderabad eligible]
    O --> P{Production/simulated payment path healthy?}
    P -->|No| P1[Set DRServeReady=0\nStop new writes if no safe region]
    P -->|Yes| Q[Record RTO/RPO\nReconcile in-flight window]

    Q --> R{Mumbai begins recovering?}
    R -->|Yes| R1[Quarantine Mumbai\nNo automatic failback]
    R -->|No| S[Continue Hyderabad operation]
    R1 --> T[Re-establish replication\nPlanned switchover later]
    S --> T
```

## Quantified branch rules

| Decision | Continue RB-01 when | Branch / stop when |
|----------|---------------------|--------------------|
| Failure domain | Multiple services/AZs in Mumbai fail | Single AZ only → RB-10 |
| Partition test | Mumbai unavailable to independent external observers | Mumbai still serves but cross-region link fails → RB-05 |
| DR health | Hyderabad EKS and stateful targets reachable | Hyderabad also unhealthy → dual-region incident |
| Tier-0/1 exposure | Bounded and within approved limits | Unknown or >60s → explicit risk decision |
| Aurora | Secondary valid and promotion succeeds | Promotion/integrity failure → no DNS exposure |
| Idempotency | Duplicate synthetic replay produces no second transaction | Duplicate financial action → stop immediately |
| DNS gate | `DRServeReady=1` after all technical gates | Endpoint reachability alone is insufficient |
| Failback | Reconciliation and planned switchover approved | Never auto-return traffic on Mumbai recovery |
