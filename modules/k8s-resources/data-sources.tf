# --- connection
data "aws_eks_cluster" "cluster" {
  name = var.eks_config_cluster_name
  # depends_on = [var.eks_config_iam_cluster_oidc_issuer_url]
}


data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_config_cluster_name
  # depends_on = [var.eks_config_iam_cluster_oidc_issuer_url]
}


# --- aws resources
data "aws_elb_hosted_zone_id" "commons" {}
data "aws_route53_zone" "commons" {
  #  name         = "${var.common_domain_name}."
  #  private_zone = false
  name         = "${var.common_private_zone}."
  private_zone = true
  depends_on   = [var.common_private_zone]
}

#--- argocd
data "kubectl_path_documents" "argocd_setup" {
  pattern = "${path.module}/templates/argocd/common/01-argocd-setup.yaml"

  vars = {
    argocd_namespace = var.k8s_namespace_argocd
  }
}
data "kubectl_path_documents" "argocd_ingress_config" {
  pattern = "${path.module}/templates/argocd/common/02-argocd-ingress-config.yaml"

  vars = {
    ingress_class_name = var.k8s_ingress_class_name
    metadata_name      = "${var.eks_config_cluster_name}-${var.aws_route53_record_argocd_server.name}"
    metadata_namespace = var.k8s_namespace_argocd
    #    spec_rules_host    = "${var.aws_route53_record_argocd_server.name}.${var.common_domain_name}"
    spec_rules_host = "${var.aws_route53_record_argocd_server.name}.${var.common_private_zone}"
  }
}

data "kubectl_path_documents" "argocd_image_updater_setup" {
  pattern = "${path.module}/templates/argocd/common/03-argocd-image-updater.yaml"

  vars = {
    AWS_ACCOUNT_ID = var.common_aws_caller_identity
    AWS_IAM_ROLE   = "${var.eks_config_cluster_name}-ecr"
    # annotation
  }
}

data "kubectl_path_documents" "argocd_repo_secret" {
  pattern = "${path.module}/templates/argocd/common/04-argocd-repo-secret.yaml"

  vars = {
    metadata_namespace = var.k8s_namespace_argocd
    repo_username      = var.k8s_argocd_repo_username
    repo_password      = var.k8s_argocd_repo_password
  }
}

data "kubectl_path_documents" "argocd_master_applicationset" {
  pattern = "${path.module}/templates/argocd/common/05-argocd-master-applicationset.yaml"

  vars = {
    metadata_namespace = var.k8s_namespace_argocd
  }
}

data "kubectl_path_documents" "argocd_vault_secret" {
  pattern = "${path.module}/templates/argocd/common/06-argocd-vault-secret.yaml"

  vars = {
    metadata_namespace = var.k8s_namespace_argocd
  }
}