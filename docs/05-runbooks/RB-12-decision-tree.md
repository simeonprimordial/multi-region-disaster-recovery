# RB-12 Decision Tree — Cascading Microservice Failure

```mermaid
flowchart TD
 A[Payment success degrades] --> B{Fraud-detection is root toxic dependency?}
 B -->|No| C[Use actual DB/MSK/Redis/region runbook]
 B -->|Yes| D[Open Istio circuit / fail fast]
 D --> E{Recent fraud deployment correlated?}
 E -->|Yes| F[Rollback to last verified revision]
 E -->|No| G{Fraud healthy but overloaded?}
 G -->|Yes| H[Scale cautiously after downstream capacity check]
 G -->|No| I{Risk Officer approves bounded degraded mode?}
 I -->|No| J[Fail closed for affected/high-risk traffic]
 I -->|Yes| K[Permit only approved low-risk cohort/amount/time window]
 F --> L{Fraud error <1% and P95 stable for 2m?}
 H --> L
 K --> L
 J --> L
 L -->|No| M[Keep circuit open; diagnose dependency]
 M --> D
 L -->|Yes| N[Half-open small canary]
 N --> O{Canary error <=2% for 5m?}
 O -->|No| D
 O -->|Yes| P[Progressively restore normal calls]
 P --> Q[Disable bypass and drain/reconcile backlog]
 Q --> R{Payment success >=99% for 10m?}
 R -->|No| D
 R -->|Yes| S[Close incident + PIR]
```

## Branch rules

1. Circuit breaking prevents slow/failing fraud calls from consuming transaction-processor resources indefinitely.
2. The temporary fraud bypass is not global “fraud off”; it is a Risk-approved low-risk cohort/amount/time envelope with full audit tagging.
3. High-risk traffic can remain fail-closed while low-risk traffic uses degraded mode.
4. Scaling a failing service is allowed only after checking whether the true bottleneck is downstream; otherwise scaling can amplify the cascade.
5. A known-bad application revision is rolled back before considering regional DR.
6. Hyderabad is not promoted for an application defect deployed identically there.
7. Recovery uses a half-open canary before fully closing the circuit and requires payment success ≥99% for a sustained validation window.
