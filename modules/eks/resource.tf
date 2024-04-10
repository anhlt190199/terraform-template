#--- helm spot terminator
resource "helm_release" "spot_termination_handler" {
  count = var.k8s_config_enable_spot_termination_handler ? 1 : 0

  name       = var.k8s_helm_spot_termination_handler_name
  chart      = var.k8s_helm_spot_termination_handler_chart_name
  repository = var.k8s_helm_spot_termination_handler_chart_repo
  version    = var.k8s_helm_spot_termination_handler_chart_version
  namespace  = var.k8s_helm_spot_termination_handler_chart_namespace
  verify     = false
  wait       = false

  set {
    name  = "adminService.loadBalancerSourceRanges"
    value = "ClusterIP"
  }

  depends_on = [module.eks_cluster]
}

#--- metric & autoscaler
resource "helm_release" "metric_server" {
  count      = var.k8s_config_enable_metric_server ? 1 : 0
  name       = var.k8s_helm_metric_server_handler_name
  chart      = var.k8s_helm_metric_server_handler_chart_name
  repository = var.k8s_helm_metric_server_handler_chart_repo
  version    = var.k8s_helm_metric_server_handler_chart_version
  namespace  = var.k8s_helm_metric_server_handler_chart_namespace
  verify     = false
  wait       = false

  values = [
    yamlencode({
      nodeSelector = {
        "node.kubernetes.io/environment" = "development"
      }
      tolerations = [
        {
          key      = "node.kubernetes.io/environment"
          operator = "Equal"
          value    = "development"
          effect   = "NoSchedule"
        }
      ]
      metrics = {
        enabled = true
      }
      image = {
        repository = "registry.k8s.io/metrics-server/metrics-server"
      }
    })
  ]

  depends_on = [
    kubernetes_cluster_role.iam_roles_developers,
    kubernetes_cluster_role_binding.iam_roles_developers
  ]
}
resource "helm_release" "cluster_autoscaler" {
  count      = var.k8s_config_enable_cluster_autoscaler ? 1 : 0
  name       = var.k8s_helm_autoscaler_handler_name
  chart      = var.k8s_helm_autoscaler_handler_chart_name
  repository = var.k8s_helm_autoscaler_handler_chart_repo
  version    = var.k8s_helm_autoscaler_handler_chart_version
  namespace  = var.k8s_helm_autoscaler_handler_chart_namespace
  verify     = false
  wait       = false

  values = [
    templatefile("${path.module}/templates/cluster-autoscaler-chart-values.yaml", {
      aws_region               = data.aws_region.current.name
      cluster_name             = var.eks_config_cluster_name
      service_account_name     = local.k8s_service_account_name
      service_account_role_arn = local.k8s_service_account_role_arn
    })
  ]

  set {
    name  = "extraArgs.logtostderr"
    value = true
  }

  set {
    name  = "extraArgs.v"
    value = 4
  }

  # extraArgs.stderrthreshold
  set {
    name  = "extraArgs.stderrthreshold"
    value = "info"
  }

  set {
    name  = "extraArgs.skip-nodes-with-local-storage"
    value = false
  }

  set {
    name  = "extraArgs.expander"
    value = "least-waste"
  }
  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = true
  }
  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = true
  }
  set {
    name  = "extraArgs.aws-use-static-instance-list"
    value = true
  }

  depends_on = [module.eks_cluster, helm_release.metric_server]
}
