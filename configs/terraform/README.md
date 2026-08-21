# Terraform — Multi-Region DR Composition

Root configuration and modules for the PaySecure multi-Region Active-Passive hot-standby design.

## Layout

```text
configs/terraform/
├── versions.tf / providers.tf / variables.tf / locals.tf
├── main.tf              # Root composition
├── outputs.tf
├── backend.hcl.example
├── terraform.tfvars.example
└── modules/
    ├── networking/
    ├── compute/           # EKS (primary + DR)
    ├── database/          # Aurora Global Database
    ├── dynamodb/          # Global Table
    ├── cache/             # Redis Global Datastore
    ├── messaging/         # MSK + Replicator
    ├── dns/               # Route 53 failover + health checks
    ├── monitoring/
    ├── security/          # KMS + WAF
    └── workload-identity/
```

## Regions

| Role | Region | Notes |
|------|--------|-------|
| Primary | `ap-south-1` (Mumbai) | Active EKS (~24 workers), full data plane |
| DR | `ap-south-2` (Hyderabad) | Warm EKS (~12 workers), replicated state |

## What this proves

Static composition and module wiring for networking, compute, data, DNS, security and monitoring.  
It does **not** claim live AWS apply success, measured lag, or timed RTO/RPO evidence.

## Usage (local)

```bash
cp terraform.tfvars.example terraform.tfvars
# edit values; do not commit secrets

terraform init
terraform validate
terraform plan   # requires credentials and backend
```
