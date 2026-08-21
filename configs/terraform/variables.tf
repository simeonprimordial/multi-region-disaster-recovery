variable "project" {
  description = "Project tag applied to all supported resources."
  type        = string
  default     = "paysecure-multi-region-dr"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "production"
}

variable "cost_center" {
  description = "Cost allocation tag value."
  type        = string
  default     = "payments-platform"
}

variable "dr_tier" {
  description = "Disaster-recovery tier represented by this deployment."
  type        = string
  default     = "hot-standby"

  validation {
    condition     = contains(["cold-standby", "warm-standby", "hot-standby", "active-active"], var.dr_tier)
    error_message = "dr_tier must be cold-standby, warm-standby, hot-standby, or active-active."
  }
}

variable "primary_region" {
  description = "Primary AWS Region."
  type        = string
  default     = "ap-south-1"
}

variable "dr_region" {
  description = "Disaster-recovery AWS Region."
  type        = string
  default     = "ap-south-2"
}

variable "primary_vpc_cidr" {
  description = "Primary VPC CIDR."
  type        = string
  default     = "10.20.0.0/16"
}

variable "dr_vpc_cidr" {
  description = "DR VPC CIDR."
  type        = string
  default     = "10.30.0.0/16"
}

variable "primary_azs" {
  description = "Three Availability Zones for the Mumbai VPC."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "dr_azs" {
  description = "Three Availability Zones for the Hyderabad VPC."
  type        = list(string)
  default     = ["ap-south-2a", "ap-south-2b", "ap-south-2c"]
}

variable "platform_admin_role_arn" {
  description = "Existing IAM role granted EKS cluster-admin access through the EKS Access API. Leave empty to omit the access entry during static validation."
  type        = string
  default     = ""
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the EKS public API endpoint. Restrict before applying in a real environment."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "primary_node_instance_types" {
  description = "Primary EKS managed-node-group instance types."
  type        = list(string)
  default     = ["m7g.xlarge"]
}

variable "dr_node_instance_types" {
  description = "DR EKS managed-node-group instance types."
  type        = list(string)
  default     = ["m7g.xlarge"]
}

variable "db_master_username" {
  description = "Aurora master username. The password is generated and managed by RDS/Secrets Manager."
  type        = string
  default     = "paysecure_admin"
}

variable "redis_node_type" {
  description = "Redis node class."
  type        = string
  default     = "cache.r7g.large"
}

variable "msk_broker_instance_type" {
  description = "MSK broker class."
  type        = string
  default     = "kafka.m7g.large"
}

variable "hosted_zone_id" {
  description = "Existing Route 53 public hosted-zone ID. Empty disables DNS resources for validation-only deployments."
  type        = string
  default     = ""
}

variable "service_fqdn" {
  description = "Public payment API FQDN."
  type        = string
  default     = "api.paysecure.in"
}

variable "primary_health_fqdn" {
  description = "Direct Mumbai regional health-check FQDN."
  type        = string
  default     = "mumbai.api.paysecure.in"
}

variable "dr_health_fqdn" {
  description = "Direct Hyderabad regional health-check FQDN."
  type        = string
  default     = "hyderabad.api.paysecure.in"
}

variable "primary_ingress_dns_name" {
  description = "Mumbai ingress DNS target, normally the regional ALB DNS name."
  type        = string
  default     = "mumbai-ingress.example.invalid"
}

variable "dr_ingress_dns_name" {
  description = "Hyderabad ingress DNS target, normally the regional ALB DNS name."
  type        = string
  default     = "hyderabad-ingress.example.invalid"
}

variable "enable_shield_advanced" {
  description = "Whether to create Shield Advanced protections for supplied protected resource ARNs."
  type        = bool
  default     = false
}
