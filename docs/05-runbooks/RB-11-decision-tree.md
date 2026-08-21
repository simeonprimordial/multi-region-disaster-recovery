# RB-11 Decision Tree — Ransomware Attack on Infrastructure

```mermaid
flowchart TD
 A[Ransomware/security indicators] --> B{Authoritative data affected or uncertain?}
 B -->|Yes| C[Stop unsafe financial writes]
 C --> D[Use RB-02 clean PITR/backup recovery]
 B -->|No| E{CI/CD / signing / registry trust compromised?}
 E -->|Yes| F[Freeze pipeline and revoke deploy credentials]
 F --> G[Replace runners and rebuild trusted artifacts]
 E -->|No| H[Contain compromised nodes]
 G --> H
 H --> I[Forensic metadata/snapshots]
 I --> J[Create clean node group from approved IaC/AMI]
 J --> K[Deploy only known-good immutable digests]
 K --> L{Hyderabad shares compromised identity/artifact chain?}
 L -->|Yes| M[Do not promote DR; rebuild clean trust boundary]
 L -->|No| N{Mumbai clean recovery inside RTO?}
 N -->|Yes| O[Restore trusted Mumbai capacity]
 N -->|No| P[Invoke RB-01 after DR clean-room validation]
 D --> Q{Clean pre-compromise restore exists?}
 Q -->|No| R[Controlled outage + executive/security recovery decision]
 Q -->|Yes| S[Restore, validate and reconcile]
 S --> J
 O --> T[Synthetic payment + duplicate replay + security observation]
 P --> T
 M --> T
 T --> U{Continuing suspicious access?}
 U -->|Yes| V[Recontain, expand scope and revoke remaining trust]
 U -->|No| W[Gradual service restoration + PIR]
```

## Branch rules

1. Compromised nodes are rebuilt, not cleaned and reused.
2. CI/CD compromise invalidates trust in artifacts built after the earliest compromise point until independently verified/rebuilt.
3. Backups are restored only from points whose integrity and date relative to compromise are established.
4. Hyderabad is not assumed clean merely because it is a different Region; shared credentials/artifacts can compromise both Regions.
5. Evidence preservation happens before destructive termination when operationally safe.
6. Security containment controls are never rolled back simply to improve availability.
7. Ransomware data recovery uses immutable/cross-account recovery sources and RB-02 reconciliation where authoritative records are affected.
