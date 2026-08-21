# RB-09 Decision Tree — Certificate Expiry / TLS Failure

```mermaid
flowchart TD
 A[TLS handshake/payment API failure] --> B{Backend application healthy?}
 B -->|No| C[Investigate application/cascading failure]
 B -->|Yes| D{Correct hostname/SAN presented?}
 D -->|No| E[Attach correct certificate]
 D -->|Yes| F{Certificate expired/revoked/not yet valid?}
 F -->|No| G{Trust chain complete and trusted?}
 G -->|No| H[Replace imported chain/certificate]
 G -->|Yes| I[Investigate protocol/cipher/mTLS/client pinning]
 F -->|Yes| J{Valid replacement cert already ISSUED?}
 J -->|Yes| E
 J -->|No| K[Request new DNS-validated ACM certificate]
 K --> L[Restore/create validation CNAME]
 L --> M{Certificate ISSUED inside incident budget?}
 M -->|Yes| E
 M -->|No| N{Hyderabad cert and full DR stack safe?}
 N -->|No| O[Controlled outage; continue certificate issuance]
 N -->|Yes| P[Invoke RB-01 controlled stateful promotion]
 P --> Q[DRServeReady then Route 53 exposes Hyderabad]
 E --> R[Cross-client TLS + synthetic payment + idempotency replay]
 H --> R
 I --> R
 Q --> R
 R --> S{All representative clients pass?}
 S -->|No| T[Fix SAN/chain/pinning; keep controlled exposure]
 S -->|Yes| U[Restore service and harden renewal automation]
```

## Branch rules

1. Prove the backend is healthy before treating every 443 failure as certificate-only.
2. An ACM certificate being `ISSUED` is insufficient if the ALB listener presents another certificate.
3. An already expired ACM certificate is not assumed recoverable through managed renewal; request/attach a valid replacement.
4. Mumbai and Hyderabad ACM certificates are regional and checked independently.
5. Never instruct merchants to disable certificate or hostname validation.
6. Regional DR still requires normal write-authority and `DRServeReady` gates.
7. Restoration requires cross-client trust testing plus a synthetic payment and duplicate-idempotency replay.
