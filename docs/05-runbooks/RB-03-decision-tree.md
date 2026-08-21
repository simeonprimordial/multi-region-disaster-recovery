# RB-03 Decision Tree — DNS Poisoning / DNS Infrastructure Failure

```mermaid
flowchart TD
    A[Unexpected DNS answer / SERVFAIL / TLS warning] --> B[Capture Route53 zone + NS/DS + DNSSEC + resolver evidence]
    B --> C{Route 53 authoritative records differ from approved baseline?}

    C -->|Yes| C1[Hosted-zone compromise/misconfiguration]
    C1 --> C2[Revoke/contain suspicious identity]
    C2 --> C3[Apply reviewed transactional Route 53 restoration]
    C3 --> J

    C -->|No| D{Parent NS/DS delegation changed?}
    D -->|Yes| D1[Registrar/delegation compromise]
    D1 --> D2[Lock registrar administration\nRestore approved NS/DS]
    D2 --> J

    D -->|No| E{DNSSEC KSK ACTION_NEEDED / validating SERVFAIL?}
    E -->|Yes| E1[Repair KMS/KSK access\nPreserve chain of trust]
    E1 --> J

    E -->|No| F{Route 53 authoritative service unavailable broadly?}
    F -->|Yes| F1{Critical-partner Global Accelerator pre-deployed?}
    F1 -->|Yes| F2[Activate tested static-hostname mapping path]
    F1 -->|No| F3[Record architecture gap\nNo invented raw ALB IP workaround]

    F2 --> G{Secondary authoritative DNS pre-deployed?}
    F3 --> G
    G -->|Yes| G1[Activate provider-specific pre-tested recovery]
    G -->|No| G2[Public recovery depends on Route53 restoration]
    G1 --> J
    G2 --> J

    F -->|No| H{Only specific recursive resolver returns bad answer?}
    H -->|Yes| H1[Resolver/cache poisoning branch\nKeep correct authoritative data]
    H -->|No| H2[Continue forensic diagnosis]
    H1 --> J
    H2 --> J

    J{TLS identity expected?} -->|No| J1[Escalate certificate/account compromise\nRB-09/security incident]
    J -->|Yes| K{DNS clean from multiple independent networks?}
    K -->|No| K1[Continue recovery + monitor convergence]
    K -->|Yes| L[Synthetic payment + same-idempotency replay]

    L --> M{Exactly-one financial result?}
    M -->|No| M1[Fail closed\nDo not trust recovered path]
    M -->|Yes| N[Return to monitored service\nPreserve evidence]
```

## Branch rules

| Decision | Evidence |
|----------|----------|
| Hosted-zone compromise | Route 53 records or CloudTrail change events differ from approved IaC baseline |
| Registrar compromise | Parent `NS`/`DS` differs while hosted zone itself remains correct |
| DNSSEC failure | KSK/signing state degraded; validating resolvers fail |
| Provider outage | Broad authoritative failures while regional app endpoints remain healthy |
| Resolver poisoning | Authoritative data clean; only a subset of recursive resolvers return bad/stale answers |
| Static partner bypass | Valid only if Global Accelerator/static IPs were pre-provisioned and partner-tested |
| Final recovery | DNS + delegation + DNSSEC + TLS identity + payment/idempotency test all agree |
