# RB-07 Decision Tree — DDoS Attack on Payment API

```mermaid
flowchart TD
    A[Payment API traffic spike] --> B{Legitimate merchant/event surge?}
    B -->|Yes| C[Scale normally; preserve all traffic]
    B -->|No| D{Internal retry storm?}
    D -->|Yes| E[Fix dependency + enforce backoff/jitter]
    D -->|No| F{Attack primarily L7 HTTP?}
    F -->|Yes| G[Apply pre-reviewed WAF rate/signature/managed mitigation]
    F -->|No / L3-L4| H[Shield/AWS network-layer response]

    G --> I{Attack signature sufficiently specific?}
    I -->|Yes| J[Target URI/IP/ASN/client dimension]
    I -->|No| K[Use conservative rate protection + SRT analysis]

    H --> L[AWS Shield/Support engagement]
    J --> M{Legitimate payment success >=95%?}
    K --> M
    L --> M

    M -->|Yes| N[Hold mitigation + observe]
    M -->|No| O[Scale critical EKS and enable tested degraded mode]

    O --> P{Stateful systems within safe thresholds?}
    P -->|No| Q[Protect DB/MSK/Redis; shed non-payment work]
    P -->|Yes| R{Mumbai uniquely impaired?}
    Q --> R

    R -->|No / public hostname follows attack| S[Do not fail over; keep Hyderabad as clean reserve]
    R -->|Yes| T{Hyderabad independently protected and DR-ready?}
    T -->|No| S
    T -->|Yes| U[Invoke RB-01 controlled stateful promotion]
    U --> V[Continue WAF/Shield mitigation in Hyderabad]

    N --> W{Traffic normal for cool-down window?}
    S --> W
    V --> W
    W -->|No| N
    W -->|Yes| X[Staged rollback of temporary WAF/scaling changes]
```

## Branch rules

1. A high request rate is not automatically an attack — distinguish festival/merchant demand from malicious traffic.
2. Internal retry storms are fixed at the dependency/client-retry layer, not treated as pure external DDoS.
3. Apply the narrowest WAF control that preserves legitimate payment traffic.
4. Shield-managed mitigation rule groups are not edited/deleted manually.
5. **Regional failover is not a default DDoS response.** Attackers targeting the public hostname may simply follow DNS to Hyderabad.
6. Hyderabad can be promoted only through RB-01 authority/replication/`DRServeReady` gates and must have equivalent WAF/Shield protection.
7. Idempotency and merchant retry backoff remain mandatory throughout the event.
