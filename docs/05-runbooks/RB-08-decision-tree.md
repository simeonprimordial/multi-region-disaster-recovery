# RB-08 Decision Tree — Third-Party NPCI / UPI Outage

```mermaid
flowchart TD
    A[UPI success collapses] --> B{Core payment platform healthy?}
    B -->|No| C[Investigate internal platform failure]
    C --> D{Regional or cascading service failure?}
    D -->|Regional| E[Use RB-01]
    D -->|Cascading services| F[Use RB-12]

    B -->|Yes| G{Only one bank/PSP route affected?}
    G -->|Yes| H[Isolate route; keep other healthy routes]
    G -->|No| I{Recent UPI connector deployment/change?}
    I -->|Yes| J[Rollback connector/config and retest]
    I -->|No| K[Activate UPI degraded mode]

    K --> L[Open circuit breaker for new UPI initiation]
    L --> M[Stop blind automatic retries]
    M --> N[Preserve original transaction/idempotency IDs]
    N --> O[Route ambiguous payments to status/reconciliation]

    O --> P{Partner confirms broad outage?}
    P -->|No| Q[Continue diagnostics and partner escalation]
    P -->|Yes| R[Keep UPI unavailable; surface healthy alternatives]

    R --> S{Partner restoration confirmed?}
    S -->|No| R
    S -->|Yes| T[Run representative synthetic UPI tests]
    T --> U{Success >=95% for 5 min and callbacks normal?}
    U -->|No| R
    U -->|Yes| V[Canary method restoration]

    V --> W{Timeouts/duplicates/backlog stable?}
    W -->|No| R
    W -->|Yes| X[Gradually restore full UPI traffic]
    X --> Y[Drain retry/status backlog at bounded rate]
    Y --> Z[Reconcile every ambiguous incident transaction]
```

## Branch rules

1. A nationwide external-network outage is not fixed by moving AWS Regions; the standby Region depends on the same external payment network.
2. A connector or egress failure can mimic external-network failure and must be ruled out before external attribution.
3. Ambiguous timed-out transactions are not blindly replayed with new identifiers.
4. Original transaction IDs, external references and idempotency keys persist through status checks and any contractually permitted retry.
5. New UPI initiation can be disabled while status/reconciliation workflows remain available.
6. Restoration requires partner confirmation plus synthetic evidence; one successful request is not enough.
7. Backlog drain is rate-limited to avoid causing a second outage when the external network recovers.
8. Settlement remains gated for unresolved ambiguous transactions.
