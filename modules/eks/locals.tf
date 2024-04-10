locals {
  admin_user_map_users = [
    for admin_user in var.iam_admin_users :
    {
      userarn  = "arn:aws:iam::${var.common_aws_caller_identity}:user/${admin_user}"
      username = admin_user
      groups   = ["system:masters"]
    }
  ]
  developer_user_map_users = [
    for developer_user in var.iam_developer_users :
    {
      userarn  = "arn:aws:iam::${var.common_aws_caller_identity}:user/${developer_user}"
      username = developer_user
      groups   = ["${var.common_name_prefix}-developers"]
    }
  ]
  admin_role_map_roles = [
    for admin_role in var.iam_admin_roles :
    {
      rolearn  = "arn:aws:iam::${var.common_aws_caller_identity}:role/${admin_role}"
      username = admin_role
      groups   = ["system:masters"]
    }
  ]
  developer_role_map_roles = [
    for developer_role in var.iam_developer_roles :
    {
      rolearn  = "arn:aws:iam::${var.common_aws_caller_identity}:role/${developer_role}"
      username = developer_role
      groups   = ["${var.common_name_prefix}-developers"]
    }
  ]
  iam_cluster_autoscaler_role_name = "${var.eks_config_cluster_name}-cluster-autoscaler"

  # autoscaler variable
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler-chart"
  k8s_service_account_role_arn  = "arn:aws:iam::${var.common_aws_caller_identity}:role/${local.iam_cluster_autoscaler_role_name}"
}