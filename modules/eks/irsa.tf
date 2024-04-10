#region Role with policy for cluster autoscaler
data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]
  }

}
resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = local.iam_cluster_autoscaler_role_name
  description = "EKS cluster-autoscaler policy for cluster ${var.eks_config_cluster_name}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json

  depends_on = [module.eks_cluster]
}
module "iam_assumable_role_cluster_autoscaler" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.11.1"
  create_role      = true
  role_name        = local.iam_cluster_autoscaler_role_name
  provider_url     = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [aws_iam_policy.cluster_autoscaler.arn]

  # depends_on = [aws_iam_policy.cluster_autoscaler]
}
#endregion

#region Role with assume role policy for EBS CSI driver
# data "aws_iam_policy" "ebs_csi_driver" {
#   name       = "AmazonEBSCSIDriverPolicy"
#   depends_on = [module.eks_cluster]
# }
module "iam_assumable_role_ebs_csi_driver" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.11.1"
  create_role      = true
  role_name        = "${var.eks_config_cluster_name}-ebs-csi-driver-role"
  provider_url     = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]

  # attach role to only pod (if not, will apply the whole Node) https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html
  oidc_fully_qualified_subjects  = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  # depends_on                     = [data.aws_iam_policy.ebs_csi_driver]
}
#endregion

#region Role with policy for ExternalDNS Route53
data "aws_iam_policy_document" "external_dns_route53" {
  statement {
    sid    = "externalDnsRoute53All"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    sid    = "externalDnsRoute53Own"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = ["*"]
  }

}
resource "aws_iam_policy" "external_dns_route53" {
  name = "${var.common_name_prefix}-external-dns-route53-policy"
  #  name_prefix = "${var.common_name_prefix}-external-dns-route53"
  description = "EKS cluster-autoscaler policy for cluster ${var.common_name_prefix}"
  policy      = data.aws_iam_policy_document.external_dns_route53.json
}
module "iam_assumable_role_external_dns_route53" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "5.11.1"
  create_role  = true
  role_name    = "${var.common_name_prefix}-external-dns-route53-role"
  provider_url = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:dev:${var.eks_config_cluster_name}-external-dns-route53-role"
  ]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  role_policy_arns               = [aws_iam_policy.external_dns_route53.arn]
}
#endregion

#region Role with policy for ALB Ingress Controller
resource "aws_iam_policy" "loadbalancer-policy" {
  name   = "${var.common_name_prefix}-loadbalancer-policy"
  path   = "/"
  policy = templatefile("${path.module}/templates/elastic-loadbalancer-policy.json", {})
}
module "iam_assumable_role_loadbalancer" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "5.11.1"
  create_role  = true
  role_name    = "${var.common_name_prefix}-alb-ingress-controller-role"
  provider_url = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  #  test apply all service account (remove)
  #  oidc_fully_qualified_subjects  = ["system:serviceaccount:production:${var.eks_config_cluster_name}-alb-ingress-controller-role"]
  #  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  role_policy_arns = [aws_iam_policy.loadbalancer-policy.arn]
}
#endregion

#region Role for runner s3 cache
# Role for runner s3 cache
data "aws_iam_policy_document" "runner_cache_s3" {
  statement {
    actions = ["s3:*", ]
    resources = [
      "arn:aws:s3:::${var.common_name_prefix}-runner-s3-cache/*",
    ]
  }
  # full access ecr to resource anhlt-*
  statement {
    actions = ["ecr:*", ]
    resources = [
      "arn:aws:ecr:${data.aws_region.current.name}:${var.common_aws_caller_identity}:repository/anhlt-*",
    ]
  }
}
resource "aws_iam_policy" "runner-s3-cache-policy" {
  name   = "${var.common_name_prefix}-runner-s3-cache"
  policy = data.aws_iam_policy_document.runner_cache_s3.json
  path   = "/"
}
module "iam_assumable_role_runner_s3_cache" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.11.1"
  create_role      = true
  role_name        = "${var.common_name_prefix}-runner-s3-cache-role"
  provider_url     = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [aws_iam_policy.runner-s3-cache-policy.arn]
}
#endregion

#region Role for Vault
# Policy vault KMS
data "aws_iam_policy_document" "vault_kms" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [
      "*",
    ]
  }
}
resource "aws_iam_policy" "vault_kms" {
  name   = "${var.common_name_prefix}-vault-kms"
  policy = data.aws_iam_policy_document.vault_kms.json
  path   = "/"
}
module "iam_assumable_role_vault_kms" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.11.1"
  create_role      = true
  role_name        = "${var.common_name_prefix}-vault-kms"
  provider_url     = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [aws_iam_policy.vault_kms.arn]
}

data "aws_iam_policy_document" "kms_unseal_vault" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.common_aws_caller_identity}:root"
      ]
    }
    resources = [
      "*",
    ]
    actions = [
      "kms:*"
    ]
  }

  statement {
    principals {
      type = "AWS"
      identifiers = concat([
        for admin_role in var.iam_admin_roles :
        "arn:aws:iam::${var.common_aws_caller_identity}:role/${admin_role}"
      ], [module.iam_assumable_role_vault_kms.iam_role_arn])
    }
    resources = [
      "*",
    ]
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
  }
}
resource "aws_kms_key" "kms_unseal_vault" {
  description = "Vault support unseal key"

  policy = data.aws_iam_policy_document.kms_unseal_vault.json
}
resource "aws_kms_alias" "kms_unseal_vault" {
  name          = "alias/kms-unseal-vault-key"
  target_key_id = aws_kms_key.kms_unseal_vault.key_id
}
#endregion

#region Role app
#region Role for s3 bucket anhlt-file-dev
data "aws_iam_policy_document" "anhlt_file_dev_s3" {
  statement {
    actions = ["s3:*", ]
    resources = [
      "arn:aws:s3:::anhlt-dev-*",
      # "arn:aws:s3:::${var.common_name_prefix}-runner-s3-cache/*",
    ]
  }
}
resource "aws_iam_policy" "anhlt_file_dev_s3" {
  name   = "${var.common_name_prefix}-anhlt-file-dev-s3"
  policy = data.aws_iam_policy_document.anhlt_file_dev_s3.json
  path   = "/"
}
module "iam_assumable_role_anhlt_file_dev_s3" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.11.1"
  create_role      = true
  role_name        = "${var.common_name_prefix}-anhlt-file-dev-s3"
  provider_url     = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [aws_iam_policy.anhlt_file_dev_s3.arn]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:dev:anhlt-file-dev"
  ]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}
#endregion

#region anhlt-core-staging
module "iam_assumable_role_anhlt_core_staging" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "5.11.1"
  create_role  = true
  role_name    = "anhlt-core-staging"
  provider_url = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:staging:anhlt-core-staging"
  ]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}
#endregion

#region anhlt-notification-staging
module "iam_assumable_role_anhlt_notification_staging" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "5.11.1"
  create_role  = true
  role_name    = "anhlt-notification-staging"
  provider_url = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:staging:anhlt-notification-staging"
  ]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}
#endregion

#region anhlt-oidc-staging
module "iam_assumable_role_anhlt_oidc_staging" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "5.11.1"
  create_role  = true
  role_name    = "anhlt-oidc-staging"
  provider_url = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:staging:anhlt-oidc-staging"
  ]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}
#endregion

#region anhlt-core-production
module "iam_assumable_role_anhlt_core_production" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "5.11.1"
  create_role  = true
  role_name    = "anhlt-core-production"
  provider_url = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:production:anhlt-core-production"
  ]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}
#endregion

#region anhlt-notification-production
module "iam_assumable_role_anhlt_notification_production" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "5.11.1"
  create_role  = true
  role_name    = "anhlt-notification-production"
  provider_url = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:production:anhlt-notification-production"
  ]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}
#endregion

#region anhlt-oidc-production
module "iam_assumable_role_anhlt_oidc_production" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "5.11.1"
  create_role  = true
  role_name    = "anhlt-oidc-production"
  provider_url = replace(var.iam_cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:production:anhlt-oidc-production"
  ]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}
#endregion
#endregion
