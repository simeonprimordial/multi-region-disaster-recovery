# RB-02 Decision Tree — Database Corruption

```mermaid
flowchart TD
    A[Transaction integrity/reconciliation alert] --> B[Stop suspected corrupting writer\nPause settlement/reconciliation mutation]
    B --> C[Preserve corrupted snapshot + audit evidence]
    C --> D{Is corruption source identified?}

    D -->|Yes| D1[Rollback/fix offending application]
    D -->|No| D2[Keep affected writer paused\nExpand forensic investigation]
    D1 --> E
    D2 --> E

    E{Is Hyderabad replica clean?} -->|Yes| F{Are corrupt writes still propagating?}
    E -->|No / Unknown| G[Do not treat replica as backup]
    F -->|Yes| F1[Optional IC/DB-approved detach\nKeep standalone cluster isolated]
    F -->|No| H[Leave global topology intact]
    F1 --> I
    H --> I
    G --> I

    I{Is corruption bounded to an enumerable row/column set?} -->|No| J[PITR to new Aurora cluster]
    I -->|Yes| K{Can correct values be reconstructed from authoritative evidence?}
    K -->|Yes| L[Build reviewed reconciliation table\nTargeted transactional correction]
    K -->|No| J

    J --> M{Will full PITR cutover discard legitimate post-restore-time transactions?}
    M -->|Yes| N[Use PITR as clean comparison source\nForward-reconcile legitimate writes]
    M -->|No| O[Validate restored cluster as cutover candidate]

    L --> P[Validate zero unexplained mismatches]
    N --> P
    O --> P

    P --> Q{New invalid writes still appearing?}
    Q -->|Yes| Q1[Pause writer again\nExpand corruption window]
    Q -->|No| R[Resume transaction processor in controlled mode]

    R --> S[Synthetic payment + idempotency replay]
    S --> T{Exactly-once financial outcome?}
    T -->|No| T1[STOP\nDo not resume settlement]
    T -->|Yes| U[Resume reconciliation observe-first]

    U --> V{All affected transactions reconciled or exception-tracked?}
    V -->|No| V1[Keep settlement paused\nContinue partner reconciliation]
    V -->|Yes| W[Resume settlement]

    W --> X[Verify Global Database topology\nClose only after financial reconciliation]
```

## Primary branch criteria

| Decision | Manual repair path | PITR / reference path |
|----------|--------------------|----------------------|
| Scope | Small, enumerable set | Unknown or broad table/relationship corruption |
| Fields | Specific columns/status values | Amounts, references, schema relationships uncertain |
| Correct truth | Reconstructable from bank/network/audit evidence | Not deterministically reconstructable row-by-row |
| Post-corruption legitimate writes | Must be preserved | Full cutover requires forward reconciliation/replay |
| Replica state | May also be corrupt | Clean replica useful only if verified and safely isolated |
