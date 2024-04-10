module "vpc" {
  source = "./modules/vpc"

  eks_config_cluster_name = var.eks_config_cluster_name
  common_environment      = var.common_environment

  vpc_main_network_block      = var.vpc_main_network_block
  vpc_subnet_prefix_extension = var.vpc_subnet_prefix_extension
  vpc_zone_offset             = var.vpc_zone_offset

  common_private_zone = var.common_private_zone
}

module "vpn" {
  source                  = "./modules/vpn"
  instance_type           = var.vpn_instance_type
  vpc_id                  = module.vpc.vpc_id
  subnet_id               = module.vpc.public_subnets[0]
  eks_config_cluster_name = var.eks_config_cluster_name
  common_domain_name      = var.common_domain_name
}

module "common" {
  source             = "./modules/common"
  common_name_prefix = var.eks_config_cluster_name
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "AmazonEKSVPCCNIRole"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = {
    Project = "anhlt"
    Name    = "AmazonEKSVPCCNIRole"
  }
}

module "eks" {
  source = "./modules/eks"

  common_name_prefix                   = var.eks_config_cluster_name
  common_aws_caller_identity           = data.aws_caller_identity.current.account_id
  eks_config_create_aws_auth_configmap = var.eks_config_create_aws_auth_configmap
  common_private_zone                  = var.common_private_zone
  vpc_id                               = module.vpc.vpc_id
  vpc_private_subnets                  = [module.vpc.private_subnets[0],module.vpc.private_subnets[1],module.vpc.private_subnets[2]]
  vpn_security_group_id                = module.vpn.security_group_id
  iam_admin_users                      = var.iam_admin_users
  iam_developer_users                  = var.iam_developer_users
  iam_admin_roles                      = var.iam_admin_roles
  iam_developer_roles                  = var.iam_developer_roles
  #  iam_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  iam_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url

  vpc_cni_role_arn = module.vpc_cni_irsa.iam_role_arn

  eks_config_cluster_environment       = var.common_environment
  eks_config_cluster_name              = var.eks_config_cluster_name
  eks_config_cluster_version           = var.eks_config_cluster_version
  eks_config_manage_aws_auth_configmap = var.eks_config_manage_aws_auth_configmap
  eks_config_enable_irsa               = var.eks_config_enable_irsa
  #  eks_managed_node_groups = var.eks_managed_node_groups
  eks_managed_node_groups = local.eks_managed_node_groups

  # coredns
  k8s_config_core_dns_node_selector = var.k8s_config_core_dns_node_selector
  k8s_config_core_dns_tolerations   = var.k8s_config_core_dns_tolerations
}

module "k8s_resources" {
  source = "./modules/k8s-resources"

  # common environment
  common_prefix                          = var.common_prefix
  common_aws_caller_identity             = data.aws_caller_identity.current.account_id
  common_domain_name                     = var.common_domain_name
  common_environment                     = var.common_environment
  common_mail_devops                     = var.common_mail_devops
  common_private_zone                    = var.common_private_zone
  eks_config_iam_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  # vpc info
  vpc_id              = module.vpc.vpc_id
  vpc_private_subnets = [module.vpc.private_subnets[0],module.vpc.private_subnets[1],module.vpc.private_subnets[2]]

  # eks info
  eks_config_cluster_name = module.eks.cluster_name

  # argocd
  k8s_namespace_microservice       = var.k8s_namespace_microservice
  aws_route53_record_argocd_server = var.aws_route53_record_argocd_server
  k8s_argocd_repo_username         = var.k8s_argocd_repo_username
  k8s_argocd_repo_password         = var.k8s_argocd_repo_password
}

module "dev_database" {
  source                  = "./modules/dev-database"
  vpc_id                  = module.vpc.vpc_id
  subnet_id               = module.vpc.private_subnets[1]
  eks_config_cluster_name = var.eks_config_cluster_name
  common_private_zone     = var.common_private_zone
  instance_type           = var.dev_database_instance_type
  dev_database_availability_zone = var.dev_database_availability_zone
  dev_database_volume_type = var.dev_database_volume_type
  dev_database_volume_iops =  var.dev_database_volume_iops
  dev_database_volume_size = var.dev_database_volume_size

}

# module "dev_mongodb7" {
#   source                  = "./modules/dev-mongodb7"
#   vpc_id                  = module.vpc.vpc_id
#   subnet_id               = module.vpc.private_subnets[1]
#   eks_config_cluster_name = var.eks_config_cluster_name
#   common_private_zone     = var.common_private_zone
#   instance_type           = var.dev_mongodb7_instance_type
# }

#module "rancher" {
#  source                  = "./modules/rancher"
#  vpc_id                  = module.vpc.vpc_id
#  subnet_id               = module.vpc.private_subnets[2]
#  eks_config_cluster_name = var.eks_config_cluster_name
#  common_private_zone     = var.common_private_zone
#  instance_type           = var.rancher_instance_type
#}

module "aws_resources" {
  source = "./modules/aws-resources"

  # common environment
  common_name_prefix = var.eks_config_cluster_name
  vpc_id             = module.vpc.vpc_id
  #  common_prefix              = var.common_prefix
  #  common_domain_name         = var.common_domain_name
  common_environment = var.common_environment
  #  common_mail_devops         = var.common_mail_devops
  common_private_zone = var.common_private_zone

  #  docdb
  create_docdb          = var.create_docdb
  availability_zones    = module.vpc.aws_availability_zones_names
  docdb_family          = var.docdb_family
  docdb_engine_version  = var.docdb_engine_version
  docdb_master_username = var.docdb_master_username
  docdb_master_password = var.docdb_master_password
  vpc_private_subnets   = module.vpc.private_subnets
  docdb_instance_class  = var.docdb_instance_class
  docdb_instance_num    = var.docdb_instance_num
  #  vpc_security_group_id = modul

  # redis
  create_redis    = var.create_redis
  redis_version   = var.redis_version
  redis_node_type = var.redis_node_type
  # redis_num_node_groups         = var.redis_num_node_groups
  # redis_replicas_per_node_group = var.redis_replicas_per_node_group
  redis_num_cache_clusters   = var.redis_num_cache_clusters
  redis_parameter_group_name = var.redis_parameter_group_name

  # rabbitmq
  create_rabbitmq          = var.create_rabbitmq
  awsmq_engine_version     = var.awsmq_engine_version
  awsmq_username           = var.awsmq_username
  awsmq_password           = var.awsmq_password
  awsmq_host_instance_type = var.awsmq_host_instance_type

  # rds aurora postgres
  create_postgres                 = var.create_postgres
  postgres_engine_version         = var.postgres_engine_version
  postgres_username               = var.postgres_username
  postgres_password               = var.postgres_password
  postgres_deletion_protection    = var.postgres_deletion_protection
  postgres_instance_class         = var.postgres_instance_class
  postgres_cluster_instance_count = var.postgres_cluster_instance_count
}

#region Certificate
module "acm" {
  source = "./modules/acm"
  domain = var.certificate_domain
  subject_alternative_names = [
    "*.${var.certificate_domain}",
    "*.staging.${var.certificate_domain}",
    "*.preprod.${var.certificate_domain}",
  ]
}
#endregion

#region  WAF & CloudFront
data "aws_wafv2_web_acl" "waf_production_automation" {
  name     = "waf-production-automation"
  scope    = "CLOUDFRONT"
  provider = aws.global
}

data "aws_wafv2_web_acl" "waf_staging_automation" {
  name     = "WAF-staging-automation"
  scope    = "CLOUDFRONT"
  provider = aws.global
}

locals {
  cloudfront_bussines_staging = {
    for alb in data.aws_lb.alb : alb.tags["alb-business"] => {
      alb_alias    = concat(try(split(":", alb.tags["alb-alias"]), []),["business-v2.staging.dentity.com"])
      alb_dns_name = alb.dns_name
      waf_arn      = alb.tags["alb-business"] != "staging" ? aws_wafv2_web_acl.production.arn : aws_wafv2_web_acl.staging.arn
    } if alb.tags["alb-business"] == "staging"
  }

  cloudfront_bussines_production = {
    for alb in data.aws_lb.alb : alb.tags["alb-business"] => {
      alb_alias    = try(split(":", alb.tags["alb-alias"]), [])
      alb_dns_name = alb.dns_name
      waf_arn      = alb.tags["alb-business"] != "staging" ? aws_wafv2_web_acl.production.arn : aws_wafv2_web_acl.staging.arn
    } if alb.tags["alb-business"] != "staging"
  }
  mail_lists = ["dungla@vmogroup.com"]
}

module "cloudfront_staging" {
  for_each            = local.cloudfront_bussines_staging
  source              = "terraform-aws-modules/cloudfront/aws"
  version             = "3.2.0"
  aliases             = each.value.alb_alias
  comment             = "CloudFront distribution for ${var.eks_config_cluster_name} ${try(each.key, "")}"
  enabled             = true
  price_class         = var.cloudfront.staging.price_class
  retain_on_delete    = var.cloudfront.staging.retain_on_delete
  wait_for_deployment = var.cloudfront.staging.wait_for_deployment

  origin_access_identities = {
    (try(each.key, "${var.eks_config_cluster_name}-${each.key}")) = "Origin access identity for ${var.eks_config_cluster_name} ${try(each.key, "")}"
  }

  origin = {
    (try(each.key, "${var.eks_config_cluster_name}-${each.key}")) = {
      domain_name = each.value.alb_dns_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = merge(var.cloudfront.staging.cache_behavior,
    {
      target_origin_id = try(each.key, "${var.eks_config_cluster_name}-${each.key}")
    }
  )

  viewer_certificate = {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  logging_config = var.cloudfront.staging.logging_config

  geo_restriction = var.cloudfront.staging.geo_restriction

  web_acl_id = each.value.waf_arn
  depends_on = [data.aws_lb.alb, module.acm]
}

module "cloudfront_production" {
  for_each            = local.cloudfront_bussines_production
  source              = "terraform-aws-modules/cloudfront/aws"
  version             = "3.2.0"
  aliases             = each.value.alb_alias
  comment             = "CloudFront distribution for ${var.eks_config_cluster_name} ${try(each.key, "")}"
  enabled             = true
  price_class         = var.cloudfront.production.price_class
  retain_on_delete    = var.cloudfront.production.retain_on_delete
  wait_for_deployment = var.cloudfront.production.wait_for_deployment

  origin_access_identities = {
    (try(each.key, "${var.eks_config_cluster_name}-${each.key}")) = "Origin access identity for ${var.eks_config_cluster_name} ${try(each.key, "")}"
  }

  origin = {
    (try(each.key, "${var.eks_config_cluster_name}-${each.key}")) = {
      domain_name = each.value.alb_dns_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = merge(var.cloudfront.production.cache_behavior,
    {
      target_origin_id = try(each.key, "${var.eks_config_cluster_name}-${each.key}")
    }
  )

  viewer_certificate = {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  logging_config = var.cloudfront.production.logging_config

  geo_restriction = var.cloudfront.production.geo_restriction

  web_acl_id = each.value.waf_arn
  depends_on = [data.aws_lb.alb, module.acm]
}
#endregion

module "sns_ecr_alert" {
  source                 = "./modules/ecr-sns"
  for_each               = toset(local.mail_lists)
  sns_topic_name         = var.ecr_alert.sns_topic.sns_topic_name
  sns_topic_display_name = var.ecr_alert.sns_topic.sns_topic_display_name
  mail_lists             = each.key

}

module "ecr_alert_event" {
  for_each        = toset(local.mail_lists)
  source          = "./modules/ecr-notify"
  event_rule_name = var.ecr_alert.event_bridge.event_rule_name
  target_id       = var.ecr_alert.event_bridge.target_id
  sns_topic_arn   = module.sns_ecr_alert[each.key].sns_topic_arn

  depends_on = [module.sns_ecr_alert]
}

#import waf
# import {
#   to = aws_wafv2_web_acl.staging
#   id = "8343d543-14fb-438f-89bd-7ea7906408ae/WAF-staging-automation/CLOUDFRONT"
# }

# resource "aws_wafv2_web_acl" "staging" {
#   name = "WAF-staging-automation"
#   scope    = "CLOUDFRONT"
#   provider = aws.global
#   default_action {
#     allow {}
#   }

#   visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "WAFstagingautomationWAFWebACL"
#       sampled_requests_enabled   = true
#     }

# }