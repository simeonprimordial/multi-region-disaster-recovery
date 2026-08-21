locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    CostCenter  = var.cost_center
    DRTier      = var.dr_tier
    ManagedBy   = "terraform"
  }
}
