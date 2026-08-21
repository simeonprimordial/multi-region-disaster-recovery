# Data Replication Strategy Overview

## Goal

Meet **RPO < 1 minute** for financial state while keeping domestic payment-system data inside India (Mumbai + Hyderabad).

## Component Strategies

| Component | Mechanism | Engineering lag gate |
|-----------|-----------|---------------------:|
| Aurora PostgreSQL | Global Database | ≤ 30 s |
| DynamoDB | Global Tables | ≤ 15 s |
| ElastiCache Redis | Global Datastore | ≤ 60 s |
| Amazon MSK / Kafka | MSK Replicator | ≤ 30 s |
| Amazon S3 | Cross-Region replication (as needed) | Design-dependent |

## Availability vs Business Correctness

Replication provides **availability**. It does **not** by itself prove business correctness.

- Ambiguous in-flight transactions are reconciled using authoritative payment references and **idempotency keys**.
- DNS exposure of the standby Region is gated on `DRServeReady` after fencing, promotion, verification and synthetic payment + same-idempotency-key replay.
- Exactly one Region must hold financial write authority at any time (see dual-write-authority alert and RB-05).

## Data Sovereignty

Normal operation does not place Aurora payment records, DynamoDB idempotency state, Redis payment-derived state, MSK payment events, CDE data or mandatory security logs in a non-India Region.

## Evidence Boundary

Lag gates are **engineering objectives**. Measured lag and timed RTO/RPO evidence require controlled drills and are not claimed from design documents alone.
