#--- eks make
#tfsec:ignore:AWS007
module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.6.0"
  cluster_name    = var.eks_config_cluster_name
  cluster_version = var.eks_config_cluster_version

  cluster_addons = {
    coredns = {
      # most_recent = true
      addon_version = "v1.10.1-eksbuild.7"
      configuration_values = jsonencode(
        {
          "nodeSelector" : {
            "node.kubernetes.io/environment" : "development"
          },
          "tolerations" : [
            {
              "key" : "node.kubernetes.io/environment",
              "operator" : "Equal",
              "value" : "development",
              "effect" : "NoSchedule"
            }
          ]
        }
      )
    }
    kube-proxy = {
      most_recent   = true
      addon_version = "v1.27.10-eksbuild.2"
    }
    vpc-cni = {
      # most_recent = true
      addon_version            = "v1.16.4-eksbuild.2"
      service_account_role_arn = var.vpc_cni_role_arn
    }
  }

  eks_managed_node_groups = var.eks_managed_node_groups

  enable_irsa = var.eks_config_enable_irsa
  tags = {
    Environment = var.eks_config_cluster_environment,
    "karpenter.sh/discovery" = var.eks_config_cluster_name
  }

  # worker_ami_owner_id    = var.eks_config_worker_ami_owner_id
  # worker_ami_name_filter = var.eks_config_worker_ami_name_filter
  subnet_ids                = var.vpc_private_subnets
  vpc_id                    = var.vpc_id
  create_aws_auth_configmap = var.eks_config_create_aws_auth_configmap
  manage_aws_auth_configmap = var.eks_config_manage_aws_auth_configmap

  # worker_groups_launch_template = var.eks_config_worker_groups_launch_template

  # map developer & admin ARNs as kubernetes Users
  aws_auth_users = concat(local.admin_user_map_users, local.developer_user_map_users)
  aws_auth_roles = concat(local.admin_role_map_roles, local.developer_role_map_roles)

  # allow all traffic from vpn and bastion host
  cluster_security_group_additional_rules = {
    vpn = {
      description              = "Allow all traffic from vpn"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      source_security_group_id = var.vpn_security_group_id
      type                     = "ingress"
    }
  }

}

data "aws_autoscaling_groups" "eks_asg" {
  filter {
    name   = "tag:eks:cluster-name"
    values = ["${var.eks_config_cluster_name}"]
  }
}

##TODO: add to documentation
## EKS not support scale from zero if not have asg tags runner
resource "aws_autoscaling_group_tag" "asg_tag" {
  #  terraform find in array string start with
  # find string start swith worker-runner in list of string module.eks_cluster.eks_managed_node_groups_autoscaling_group_names
  for_each               = { for name in data.aws_autoscaling_groups.eks_asg.names : name => name if length(regexall("runner-amd", name)) > 0 }
  autoscaling_group_name = each.key

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/business"
    value               = "gitlab-runner"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "asg_tag_runner_arm" {
  #  terraform find in array string start with
  # find string start swith worker-runner in list of string module.eks_cluster.eks_managed_node_groups_autoscaling_group_names
  for_each               = { for name in data.aws_autoscaling_groups.eks_asg.names : name => name if length(regexall("runner-arm", name)) > 0 }
  autoscaling_group_name = each.key

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/business"
    value               = "gitlab-runner-arm"
    propagate_at_launch = true
  }
}

resource "aws_route53_record" "eks_endpoint" {
  zone_id    = data.aws_route53_zone.commons.zone_id
  name       = module.eks_cluster.cluster_name
  type       = "CNAME"
  ttl        = "300"
  records    = [module.eks_cluster.cluster_endpoint]
  depends_on = [module.eks_cluster]
}

# additional security group rules for worker to 0.0.0.0/0
resource "aws_security_group_rule" "worker_node_additional_rules_80" {
  type              = "ingress"
  description       = "Allow all traffic for health check"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks_cluster.node_security_group_id
  depends_on        = [module.eks_cluster]
}

resource "aws_security_group_rule" "worker_node_additional_rules_443" {
  type              = "ingress"
  description       = "Allow all traffic for health check"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks_cluster.node_security_group_id
  depends_on        = [module.eks_cluster]
}

resource "aws_security_group_rule" "worker_node_additional_rules_nodeport" {
  type              = "ingress"
  description       = "Allow all traffic for health check"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks_cluster.node_security_group_id
  depends_on        = [module.eks_cluster]
}

# allow all traffic from master to worker
resource "aws_security_group_rule" "worker_node_additional_rules_master" {
  type                     = "ingress"
  description              = "Allow all traffic from master"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = module.eks_cluster.node_security_group_id
  source_security_group_id = module.eks_cluster.cluster_security_group_id
  depends_on               = [module.eks_cluster]
}

# allow all traffic from worker to master
resource "aws_security_group_rule" "master_node_additional_rules_worker" {
  type                     = "ingress"
  description              = "Allow all traffic from worker"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = module.eks_cluster.cluster_security_group_id
  source_security_group_id = module.eks_cluster.node_security_group_id
  depends_on               = [module.eks_cluster]
}

#--- create developers Role using RBAC & binding
resource "kubernetes_cluster_role" "iam_roles_developers" {
  metadata {
    name = "${var.common_name_prefix}-developers"
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods", "pods/log", "deployments", "ingresses", "services"]
    verbs      = ["get", "list", "create"]
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods/portforward"]
    verbs      = ["*"]
  }

  depends_on = [
    module.eks_cluster
  ]
}
resource "kubernetes_cluster_role_binding" "iam_roles_developers" {
  metadata {
    name = "${var.common_name_prefix}-developers"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.common_name_prefix}-developers"
  }
  dynamic "subject" {
    for_each = toset(concat(var.iam_developer_users, var.iam_developer_roles))

    content {
      name      = subject.key
      kind      = "User"
      api_group = "rbac.authorization.k8s.io"
    }
  }

  depends_on = [
    kubernetes_cluster_role.iam_roles_developers
  ]
}
