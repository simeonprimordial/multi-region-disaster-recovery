# Post-Drill Review Template

> Copy this file for every exercise. Do not overwrite the template. Suggested filename: `YYYY-MM-DD-<scenario>-post-drill.md`.

## 1. Exercise identification

| Field | Value |
|-------|-------|
| Exercise ID | `<DRILL-YYYY-NNN>` |
| Date / time UTC | `<start>` – `<end>` |
| Scenario / runbook | `<RB-XX — Name>` |
| Exercise level | `<1 Tabletop / 2 Test / 3 Production Component / 4 Full DR>` |
| Environment | `<test / pre-production / production>` |
| Primary Region | `ap-south-1` |
| DR Region | `ap-south-2` |
| Exercise Controller | |
| Incident Commander | |
| Independent observer | |
| Evidence scribe | |
| Overall result | `<PASS / PASS WITH FINDINGS / FAIL / STOPPED FOR SAFETY>` |

## 2. Objective

**Primary objective:** `<capability this drill intended to prove>`

**Branches tested:**  
**Out of scope:**

## 3. Pre-drill state

| Resource | Mumbai | Hyderabad | Evidence |
|----------|--------|-----------|----------|
| EKS | | | |
| Aurora | | | |
| DynamoDB | | | |
| Redis | | | |
| MSK / Replicator | | | |
| Route 53 / DRServeReady | | | |

Baseline metrics: TPS · success rate · P95/P99 · Aurora lag · DDB convergence · MSK lag · Redis lag · warm workers.

Safety checklist: no unrelated P1/P2 · approved window · synthetic credentials · rollback path · contacts · evidence logging · controller stop tested.

## 4. Inject / failure description

Injected event · method · expected vs actual blast radius · behaviour differences.

## 5. Master timeline (UTC)

| Event | Timestamp | Δ from T0 | Evidence |
|-------|-----------|----------:|----------|
| **T0** Fault/inject | | 0 s | |
| **T1** First valid detection | | | |
| Incident declared | | | |
| Primary write fencing starts | | | |
| **T3** Replication exposure accepted | | | |
| Stateful services ready | | | |
| **T5** Hyderabad EKS critical path ready | | | |
| **T6** Synthetic + duplicate replay pass | | | |
| `DRServeReady=1` | | | |
| **T7** DNS/traffic exposure starts | | | |
| **T8** First successful recovered external payment | | | |
| Failback complete | | | |
| Exercise ends | | | |

## 6. RTO result

```text
Customer RTO = T8 − T0 = ______ seconds
Engineering target ≤ 240 s · Hard objective < 300 s
```

Phase table: detection 30 s · corroborate/fence 20 s · replication safety 20 s · stateful activation 70 s · EKS readiness 40 s · synthetic 20 s · DNS 30 s · final confirmation 10 s.

## 7. RPO and data-integrity result

Aurora lag · last Mumbai commit · first Hyderabad visible · confirmed missing count · reconciled count.  
DynamoDB synthetic key convergence · duplicate replay.  
MSK topic lag · sequence gap · consumer offsets.  
Redis freshness (not financial authority).

```text
Largest confirmed unrecoverable authoritative financial gap = ______ s  (< 60 s hard)
```

## 8. Financial authority / split-brain check

Mumbai fenced at · Hyderabad granted at · overlap duration (expect 0) · any post-transfer write to old primary · uncontrolled dual writes (**must be NO**).

## 9. Business-path verification

Public HTTPS · payment-api · processor write · idempotency persist · exact duplicate replay · Kafka event · settlement/audit · latency.

**Expected duplicate replay:** exactly one financial transaction/action.

## 10. Capacity result

Hyderabad ready workers · pending pods · CPU/memory · Aurora connections · DynamoDB throttles · MSK lag · Redis.

**12-worker warm-baseline validated?** · **Cost-model change required?**

## 11–14. Command log · alerts · communications · failback

Record every command, every manual intervention, alert accuracy, audience timings, failback preconditions and issues.

## 15. Success-criteria score

Hard gates G-01…G-10. Evidence completeness score /20 across detection, decision, command trace, RPO, RTO, business-path, idempotency, communications, rollback, remediation ownership.

## 16–22. Findings · what went well · surprises · runbook/architecture changes · compliance actions · retest decision

Severity: Critical (integrity/split-brain/RTO≥300s) · High · Medium · Low.

## 23. Final sign-off

Controller · IC · Platform · Security · Database/Messaging · Compliance · Independent Observer · Executive Sponsor.

## 24. Executive summary

**One-sentence result:**  
**Decision:** DR capability proven for tested scope / remediation required / repeat full test required.  
**Top three actions:**
