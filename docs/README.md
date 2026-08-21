# Documentation Index

Portfolio documentation for a multi-Region **Active-Passive Hot Standby** disaster-recovery architecture for a payment platform (Mumbai primary · Hyderabad standby).

## Core design

| Document | Description |
|----------|-------------|
| [architecture-overview.md](./architecture-overview.md) | Topology, invariants, control-plane map |
| [02-multi-region-design/comparison-summary.md](./02-multi-region-design/comparison-summary.md) | Weighted scoring of DR tiers |
| [02-multi-region-design/active-passive-recovery-budget.md](./02-multi-region-design/active-passive-recovery-budget.md) | 240 s critical path, Tier 0–3, RPO gates |

## Data & traffic

| Document | Description |
|----------|-------------|
| [03-data-replication/replication-overview.md](./03-data-replication/replication-overview.md) | Aurora / DynamoDB / Redis / MSK strategies |
| [04-dns-failover/dns-failover-overview.md](./04-dns-failover/dns-failover-overview.md) | Route 53 as traffic exposure + DRServeReady |
| [07-data-sovereignty/overview.md](./07-data-sovereignty/overview.md) | India-resident payment state |

## Operations

| Document | Description |
|----------|-------------|
| [05-runbooks/README.md](./05-runbooks/README.md) | Catalogue of 12 scenarios + decision trees |
| [08-dr-drill-plan/drill-success-criteria.md](./08-dr-drill-plan/drill-success-criteria.md) | PASS / FAIL gates, evidence scoring |
| [08-dr-drill-plan/annual-drill-plan.md](./08-dr-drill-plan/annual-drill-plan.md) | 12-month exercise programme |

## Cost & risk

| Document | Description |
|----------|-------------|
| [06-cost-analysis/cost-summary.md](./06-cost-analysis/cost-summary.md) | Four-tier infrastructure cost model |
| [06-cost-analysis/roi-summary.md](./06-cost-analysis/roi-summary.md) | Risk-adjusted ROI; why Hot Standby is selected |

## Evidence boundary

Architecture, runbooks, cost/ROI models and static configs are **documented**. Timed RTO/RPO drill evidence, live AWS deployment proof, and regulatory/PCI certification are **not claimed** from this repository alone.
