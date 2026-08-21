# Terraform — Multi-Region DR Skeleton

Infrastructure-as-code layout for an **Active-Passive Hot Standby** payment platform:

| Region | Role |
|--------|------|
| `ap-south-1` (Mumbai) | Primary payment write path |
| `ap-south-2` (Hyderabad) | Continuously testable hot standby |

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider version constraints |
| `providers.tf` | Dual AWS providers (`primary` / `dr`) with default tags |
| `variables.tf` | Region, project, environment, DR-tier, cost-center inputs |
| `locals.tf` | Shared tags |
| `main.tf` | Module composition skeleton (networking, EKS, Aurora Global, DynamoDB Global Tables, Redis Global Datastore, MSK + Replicator, Route 53 failover, monitoring, security) |
| `outputs.tf` | Region and project outputs; module outputs wired when modules are instantiated |

## Design notes

- **Dual-provider pattern** keeps primary and DR resources in separate regional contexts while sharing a single root module.
- **Backend** is S3 (configured at init time); state is not committed.
- **Modules** are compositional stubs suitable for portfolio demonstration. Production values (CIDRs, instance classes, certificate ARNs, health-check IDs) are environment-specific and intentionally placeholder.
- **Financial-authority controls** (fencing, promotion, `DRServeReady`) live in operational runbooks and automation — not in Terraform apply alone.

## Usage (illustrative)

```bash
terraform init
terraform plan -var-file=env/example.tfvars
# apply only in an authorised non-production account after review
```

This repository does **not** claim a live multi-Region deployment. Static structure and design intent are the portfolio deliverable.
