module "networking_primary" {
  source = "./modules/networking"

  providers = {
    aws = aws.primary
  }

  name_prefix = "paysecure-mumbai"
  region      = var.primary_region
  vpc_cidr    = var.primary_vpc_cidr
  azs         = var.primary_azs
  tags        = merge(local.common_tags, { RegionRole = "primary" })
}

module "networking_dr" {
  source = "./modules/networking"

  providers = {
    aws = aws.dr
  }

  name_prefix = "paysecure-hyderabad"
  region      = var.dr_region
  vpc_cidr    = var.dr_vpc_cidr
  azs         = var.dr_azs
  tags        = merge(local.common_tags, { RegionRole = "secondary" })
}

resource "aws_ec2_transit_gateway_peering_attachment" "primary_to_dr" {
  provider = aws.primary

  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = var.dr_region
  peer_transit_gateway_id = module.networking_dr.transit_gateway_id
  transit_gateway_id      = module.networking_primary.transit_gateway_id

  tags = merge(local.common_tags, {
    Name = "paysecure-mumbai-hyderabad-tgw-peering"
  })
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "dr" {
  provider = aws.dr

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.primary_to_dr.id

  tags = merge(local.common_tags, {
    Name = "paysecure-mumbai-hyderabad-tgw-peering-accepter"
  })
}

data "aws_caller_identity" "current" {
  provider = aws.primary
}

module "security_primary" {
  source = "./modules/security"

  providers = {
    aws = aws.primary
  }

  name_prefix                  = "paysecure-mumbai"
  waf_rate_limit_per_5_minutes = 30000
  enable_shield_advanced       = var.enable_shield_advanced
  shield_protected_resource_arns = []
  tags                         = merge(local.common_tags, { RegionRole = "primary" })
}

module "security_dr" {
  source = "./modules/security"

  providers = {
    aws = aws.dr
  }

  name_prefix                  = "paysecure-hyderabad"
  waf_rate_limit_per_5_minutes = 30000
  enable_shield_advanced       = var.enable_shield_advanced
  shield_protected_resource_arns = []
  tags                         = merge(local.common_tags, { RegionRole = "secondary" })
}

module "compute_primary" {
  source = "./modules/compute"

  providers = {
    aws = aws.primary
  }

  cluster_name            = "paysecure-mumbai"
  subnet_ids              = module.networking_primary.private_subnet_ids
  kms_key_arn             = module.security_primary.kms_key_arn
  platform_admin_role_arn = var.platform_admin_role_arn
  public_access_cidrs     = var.public_access_cidrs
  instance_types          = var.primary_node_instance_types
  desired_size            = 24
  min_size                = 12
  max_size                = 36
  tags                    = merge(local.common_tags, { RegionRole = "primary" })
}

module "compute_dr" {
  source = "./modules/compute"

  providers = {
    aws = aws.dr
  }

  cluster_name            = "paysecure-hyderabad"
  subnet_ids              = module.networking_dr.private_subnet_ids
  kms_key_arn             = module.security_dr.kms_key_arn
  platform_admin_role_arn = var.platform_admin_role_arn
  public_access_cidrs     = var.public_access_cidrs
  instance_types          = var.dr_node_instance_types
  desired_size            = 12
  min_size                = 12
  max_size                = 36
  tags                    = merge(local.common_tags, { RegionRole = "secondary" })
}

module "database" {
  source = "./modules/database"

  providers = {
    aws    = aws.primary
    aws.dr = aws.dr
  }

  name_prefix              = "paysecure"
  engine_version           = "15.4"
  database_name            = "paysecure"
  master_username          = var.db_master_username
  primary_vpc_id           = module.networking_primary.vpc_id
  primary_vpc_cidr         = var.primary_vpc_cidr
  primary_subnet_ids       = module.networking_primary.private_subnet_ids
  primary_kms_key_arn      = module.security_primary.kms_key_arn
  dr_vpc_id                = module.networking_dr.vpc_id
  dr_vpc_cidr              = var.dr_vpc_cidr
  dr_subnet_ids            = module.networking_dr.private_subnet_ids
  dr_kms_key_arn           = module.security_dr.kms_key_arn
  primary_instance_class   = "db.r6g.2xlarge"
  primary_instance_count   = 3
  secondary_instance_class = "db.r6g.xlarge"
  secondary_instance_count = 2
  tags                     = local.common_tags
}

module "dynamodb" {
  source = "./modules/dynamodb"

  providers = {
    aws = aws.primary
  }

  table_name          = "paysecure-sessions-idempotency"
  read_capacity       = 10000
  write_capacity      = 5000
  dr_region           = var.dr_region
  primary_kms_key_arn = module.security_primary.kms_key_arn
  dr_kms_key_arn      = module.security_dr.kms_key_arn
  tags                = local.common_tags
}

module "cache" {
  source = "./modules/cache"

  providers = {
    aws    = aws.primary
    aws.dr = aws.dr
  }

  name_prefix        = "paysecure"
  primary_subnet_ids = module.networking_primary.private_subnet_ids
  primary_vpc_id     = module.networking_primary.vpc_id
  primary_vpc_cidr   = var.primary_vpc_cidr
  dr_subnet_ids      = module.networking_dr.private_subnet_ids
  dr_vpc_id          = module.networking_dr.vpc_id
  dr_vpc_cidr        = var.dr_vpc_cidr
  node_type          = var.redis_node_type
  tags               = local.common_tags
}

module "messaging" {
  source = "./modules/messaging"

  providers = {
    aws    = aws.primary
    aws.dr = aws.dr
  }

  name_prefix          = "paysecure"
  primary_subnet_ids   = module.networking_primary.private_subnet_ids
  primary_vpc_id       = module.networking_primary.vpc_id
  primary_vpc_cidr     = var.primary_vpc_cidr
  primary_kms_key_arn  = module.security_primary.kms_key_arn
  dr_subnet_ids        = module.networking_dr.private_subnet_ids
  dr_vpc_id            = module.networking_dr.vpc_id
  dr_vpc_cidr          = var.dr_vpc_cidr
  dr_kms_key_arn       = module.security_dr.kms_key_arn
  broker_instance_type = var.msk_broker_instance_type
  tags                 = local.common_tags
}

module "dns" {
  source = "./modules/dns"

  providers = {
    aws = aws.primary
  }

  enabled                   = var.hosted_zone_id != ""
  hosted_zone_id            = var.hosted_zone_id
  service_fqdn              = var.service_fqdn
  primary_health_fqdn       = var.primary_health_fqdn
  dr_health_fqdn            = var.dr_health_fqdn
  primary_target_dns_name   = var.primary_ingress_dns_name
  dr_target_dns_name        = var.dr_ingress_dns_name
  dr_serve_ready_alarm_name = module.monitoring_dr.dr_serve_ready_alarm_name
  primary_payment_alarm_name = module.monitoring_primary.payment_path_alarm_name
  tags                      = local.common_tags
}

module "monitoring_primary" {
  source = "./modules/monitoring"

  providers = {
    aws = aws.primary
  }

  name_prefix                 = "paysecure-mumbai"
  region_role                 = "primary"
  aurora_cluster_id           = module.database.primary_cluster_id
  msk_cluster_name            = module.messaging.primary_cluster_name
  create_dr_serve_ready_alarm = false
  tags                        = local.common_tags
}

module "monitoring_dr" {
  source = "./modules/monitoring"

  providers = {
    aws = aws.dr
  }

  name_prefix                 = "paysecure-hyderabad"
  region_role                 = "secondary"
  aurora_cluster_id           = module.database.secondary_cluster_id
  msk_cluster_name            = module.messaging.secondary_cluster_name
  create_dr_serve_ready_alarm = true
  tags                        = local.common_tags
}
