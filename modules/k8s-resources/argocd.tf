#region argocd setup (resource & ingress)
resource "kubernetes_namespace" "argocd" {
  count = var.k8s_argocd_is_created ? 1 : 0

  metadata {
    annotations = {
      name = var.k8s_namespace_argocd
    }
    name = var.k8s_namespace_argocd
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubectl_manifest" "argocd_setup" {
  count     = length(data.kubectl_path_documents.argocd_setup.documents)
  yaml_body = element(data.kubectl_path_documents.argocd_setup.documents, count.index)

  override_namespace = var.k8s_namespace_argocd

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

resource "kubectl_manifest" "argocd_ingress_config" {
  count     = length(data.kubectl_path_documents.argocd_ingress_config.documents)
  yaml_body = element(data.kubectl_path_documents.argocd_ingress_config.documents, count.index)

  override_namespace = var.k8s_namespace_argocd

  depends_on = [
    #    helm_release.ingress_nginx,
    kubectl_manifest.argocd_setup
    #    aws_route53_record.argocd_server
  ]
}

# iam role
data "aws_iam_policy_document" "anhlt-ecr" {
  statement {
    sid    = replace("${var.eks_config_cluster_name}-ecr", "-", "")
    effect = "Allow"

    # access list & read
    actions = [
      "ecr:GetRegistryPolicy",
      "ecr:DescribeImageScanFindings",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeRegistry",
      "ecr:DescribePullThroughCacheRules",
      "ecr:DescribeImageReplicationStatus",
      "ecr:GetAuthorizationToken",
      "ecr:ListTagsForResource",
      "ecr:ListImages",
      "ecr:BatchGetRepositoryScanningConfiguration",
      "ecr:GetRegistryScanningConfiguration",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetRepositoryPolicy",
      "ecr:GetLifecyclePolicy"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "anhlt-ecr" {
  name        = "${var.eks_config_cluster_name}-ecr"
  description = "EKS cluster-autoscaler policy for cluster ${var.eks_config_cluster_name}"
  policy      = data.aws_iam_policy_document.anhlt-ecr.json
}

module "iam_assumable_role_anhlt-ecr" {
  source                         = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                        = "5.11.1"
  create_role                    = true
  role_name                      = "${var.eks_config_cluster_name}-ecr"
  provider_url                   = replace(var.eks_config_iam_cluster_oidc_issuer_url, "https://", "")
  role_policy_arns               = [aws_iam_policy.anhlt-ecr.arn]
  oidc_fully_qualified_subjects  = ["system:serviceaccount:${var.k8s_namespace_argocd}:argocd-image-updater"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  depends_on = [
    aws_iam_policy.anhlt-ecr
  ]
}

# argocd image updater
resource "kubectl_manifest" "argocd_image_updater_setup" {
  count     = length(data.kubectl_path_documents.argocd_image_updater_setup.documents)
  yaml_body = element(data.kubectl_path_documents.argocd_image_updater_setup.documents, count.index)

  override_namespace = var.k8s_namespace_argocd

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# argocd repo secret
resource "kubectl_manifest" "argocd_repo_secret" {
  count     = length(data.kubectl_path_documents.argocd_repo_secret.documents)
  yaml_body = element(data.kubectl_path_documents.argocd_repo_secret.documents, count.index)

  override_namespace = var.k8s_namespace_argocd

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# argocd master applicationset
resource "kubectl_manifest" "argocd_master_applicationset" {
  count     = length(data.kubectl_path_documents.argocd_master_applicationset.documents)
  yaml_body = element(data.kubectl_path_documents.argocd_master_applicationset.documents, count.index)

  override_namespace = var.k8s_namespace_argocd

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# annotate the service account to allow the image updater to work
#endregion

resource "kubectl_manifest" "argocd_vault_secret" {
  count     = length(data.kubectl_path_documents.argocd_vault_secret.documents)
  yaml_body = element(data.kubectl_path_documents.argocd_vault_secret.documents, count.index)

  override_namespace = var.k8s_namespace_argocd

  depends_on = [
    kubernetes_namespace.argocd
  ]
}