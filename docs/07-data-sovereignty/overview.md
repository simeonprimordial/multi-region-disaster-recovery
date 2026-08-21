# Data Sovereignty Overview

## Topology Decision

Domestic payment-system state and mandatory security evidence remain **inside India**:

| Role | Region |
|------|--------|
| Primary payment / data | Mumbai `ap-south-1` |
| Hot-standby / DR | Hyderabad `ap-south-2` |

Normal operation does **not** place the following in a non-India Region:

- Aurora payment records  
- DynamoDB idempotency state  
- Redis payment-derived state  
- MSK payment events  
- Cardholder data environment (CDE) data  
- Mandatory security logs  

## Design vs Certification

This repository provides **architecture and compliance mapping**. It does **not** claim:

- regulatory authorisation  
- NPCI / UPI operational approval  
- PCI DSS certification  
- legal or auditor sign-off  

Those remain external processes.

## Financial Write Authority

Exactly one Region holds payment write authority at any time. Cross-Region replication supports recovery; it does not create dual-write authority. DNS exposure of the standby is gated on `DRServeReady` after fencing, promotion, verification and synthetic payment + idempotency replay.
