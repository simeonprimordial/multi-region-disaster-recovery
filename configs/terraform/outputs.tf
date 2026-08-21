output "primary_region" {
  description = "Primary payment Region"
  value       = var.primary_region
}

output "dr_region" {
  description = "Hot-standby / DR Region"
  value       = var.dr_region
}

output "project" {
  description = "Project tag value"
  value       = var.project
}

output "environment" {
  description = "Environment tag value"
  value       = var.environment
}

output "dr_tier" {
  description = "Selected DR tier (e.g. hot-standby)"
  value       = var.dr_tier
}

# Module outputs would be wired here once concrete module instances exist, e.g.:
# output "primary_eks_cluster_name" { value = module.eks_primary.cluster_name }
# output "dr_eks_cluster_name"      { value = module.eks_dr.cluster_name }
# output "aurora_global_cluster_id" { value = module.aurora.global_cluster_id }
# output "route53_health_check_ids" { value = module.dns.health_check_ids }
