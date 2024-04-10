#--- addon ebs driver
data "aws_eks_addon_version" "aws_ebs_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = module.eks_cluster.cluster_version
  most_recent        = true
  depends_on         = [module.eks_cluster]
}

resource "aws_eks_addon" "aws_ebs_driver" {
  cluster_name = module.eks_cluster.cluster_name
  addon_name   = "aws-ebs-csi-driver"

  #TODO: move to variable
  addon_version            = "v1.28.0-eksbuild.1"
  service_account_role_arn = module.iam_assumable_role_ebs_csi_driver.iam_role_arn
  #   json to string
  configuration_values = jsonencode({
    "controller" : {
      "nodeSelector" : {
        "node.kubernetes.io/environment" : "development"
      },
      "tolerations" : [
        {
          "key" : "node.kubernetes.io/environment",
          "operator" : "Equal",
          "value" : "development",
          "effect" : "NoSchedule",
        }
      ]
    }
  })

  depends_on = [
    data.aws_eks_addon_version.aws_ebs_driver,
    module.iam_assumable_role_ebs_csi_driver
  ]
}
