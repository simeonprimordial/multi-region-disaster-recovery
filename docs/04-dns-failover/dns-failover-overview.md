# DNS Failover Design Overview

## Role of DNS

Route 53 is used as a **traffic-exposure** mechanism, not as the creator of financial write authority.

```text
Customers / Merchants / Banks
            |
         Route 53
        failover DNS
        /          \
       /            \
Mumbai PRIMARY      Hyderabad DR
(health checks)     (health checks + DRServeReady)
```

## Design Principles

1. **Primary health checks** monitor the Mumbai payment path (ALB + application deep health).
2. **Secondary (DR) health checks** monitor Hyderabad independently and are gated by a **DRServeReady** signal.
3. **DNS never promotes databases or opens write authority.** Promotion, fencing, and synthetic payment + idempotency replay must complete before the standby is considered ready to serve.
4. Failover records use a short TTL consistent with the RTO budget (engineering target end-to-end ≤ 240 s).
5. Calculated health checks can combine endpoint status with CloudWatch alarms (e.g. lag gates, capacity).

## Financial-Safety Gate

```text
regional failure detected
        → corroborate
        → fence old-primary writes
        → bound replication exposure
        → promote required state
        → verify DR workloads
        → synthetic payment + same-idempotency-key replay
        → DRServeReady = 1
        → Route 53 may expose Hyderabad
```

Until `DRServeReady = 1`, the secondary health check remains unhealthy so customer traffic is not steered to a Region that is not yet authorised to process payments.

## Configuration Artefacts

- Health-check definitions (HTTP deep-health paths)
- Failover routing policy (PRIMARY / SECONDARY)
- Optional calculated health checks tied to CloudWatch alarms
- Emergency contingency for DNS infrastructure failure (see RB-03)

Exact hostnames, health-check IDs and hosted-zone IDs are environment-specific and are not committed as live production values.
