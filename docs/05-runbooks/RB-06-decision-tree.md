# RB-06 Decision Tree — Cryptographic Key Compromise

```mermaid
flowchart TD
    A[Suspected CDE cryptographic compromise] --> B{What is actually compromised?}

    B -->|IAM role / access key / session| C[Quarantine principal and revoke sessions]
    B -->|KMS grant or key-policy path| D[Revoke grant / restore approved key policy]
    B -->|Imported key material exposed| E[Assume raw cryptographic material compromised]
    B -->|AWS_KMS-origin material alleged| F[Escalate to AWS Security; distinguish key use from material compromise]
    B -->|Plaintext/data key exposed only| G[Contain application/data path]

    C --> H{Unauthorised KMS use stopped?}
    D --> H
    F --> H
    G --> I{Evidence old KMS material itself is compromised?}

    H -->|No| J{Can old key be disabled without catastrophic data loss?}
    H -->|Yes| I

    J -->|Yes| K[Disable old key under Security IC approval]
    J -->|No| L[Keep old key narrowly enabled for approved decrypt only]

    E --> M[Create new multi-Region KMS key family]
    I -->|Yes / cannot disprove quickly| M
    I -->|No| N[Create replacement key as risk-reduction boundary; same-key rotation optional]
    K --> M
    L --> M
    N --> M

    M --> O[Replicate replacement key to Hyderabad]
    O --> P[Move new app encryption + DynamoDB to new key]
    P --> Q[Rotate/recreate Secrets Manager protected values]
    Q --> R[Aurora requires snapshot copy/restore under new KMS key]
    R --> S[Re-encrypt/re-wrap historical application data, S3 objects and backups]

    S --> T{All old-key dependencies removed?}
    T -->|No| U[Continue controlled migration; monitor old-key use]
    U --> T
    T -->|Yes| V[Disable old key and observe]

    V --> W{Production and decrypt validation clean?}
    W -->|No| X[Temporarily re-enable old key only after compromised access remains blocked]
    X --> U
    W -->|Yes| Y[Later retirement/deletion through separate approved change]

    A --> Z[Start regulatory/card-brand/acquirer notification assessment immediately]
    Z --> AA[Use fastest verified applicable deadline]
```

## Branch rules

1. **Identity/grant compromise is not automatically raw key-material compromise.** AWS KMS-origin key material cannot be exported through normal KMS APIs; distinguish unauthorised key *use* from actual cryptographic-material exposure.
2. **Imported material exposure is materially different.** If an external copy of imported material is exposed, the safe recovery boundary is a newly created key/material, followed by re-encryption.
3. **Disabling is reversible; deletion is not.** Initial containment must not schedule KMS deletion.
4. **Same-key rotation is not a complete response to compromised historical material.** Previous key material remains available to decrypt historical ciphertext. A new key family plus re-encryption is required for true trust-boundary replacement.
5. **Aurora encryption cannot simply be repointed to a new KMS key.** The migration path uses a snapshot copied under the replacement key and restoration to a replacement cluster.
6. **Changing an alias does not automatically re-encrypt dependent AWS resources.** Service-level migration must be verified explicitly.
7. **External reporting starts immediately.** Use the fastest verified applicable regulatory/payment-brand/acquirer timeline rather than waiting for an assumed fixed deadline.
