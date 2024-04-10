#--- common
variable "common_prefix" {
  type        = string
  description = "Common prefix name."
}
variable "common_aws_caller_identity" {
  type        = string
  description = "ID Account AWS"
}
variable "common_environment" {
  type        = string
  description = "Terraform name environment detected (current is development or production)"
}
variable "common_domain_name" {
  type        = string
  description = "Primary domain (selected from hosted zone)."
}
variable "common_private_zone" {
  type        = string
  description = "Private zone name."
}

variable "common_aws_region" {
  type        = string
  description = "common aws region"
  default     = "us-east-2"
}
variable "common_mail_devops" {
  type        = string
  description = "Mail devops team"
}

#--- vpc
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_private_subnets" {
  description = "List Private Subnet"
  type        = list(string)
}

#--- eks
variable "eks_config_cluster_name" {
  type        = string
  description = "EKS cluster name"
}
# iam_cluster_oidc_issuer_url
variable "eks_config_iam_cluster_oidc_issuer_url" {
  type        = string
  description = "EKS cluster OIDC issuer URL"
}


#--- helm nginx
variable "k8s_helm_ingress_nginx_is_created" {
  type        = bool
  description = "Allow make ingress nginx from helm-chart"
  default     = true
}
variable "k8s_namespace_ingress_nginx" {
  type        = string
  description = "Ingress nginx target namespace deployment."
  default     = "ingress-nginx"
}
variable "k8s_helm_ingress_nginx_name" {
  type        = string
  description = "[ingress-nginx] chart release."
  default     = "ingress-nginx"
}
variable "k8s_helm_ingress_nginx_chart_name" {
  type        = string
  description = "[ingress-nginx] chart name."
  default     = "ingress-nginx"
}
variable "k8s_helm_ingress_nginx_chart_repo" {
  type        = string
  description = "[ingress-nginx] chart repo."
  default     = "https://kubernetes.github.io/ingress-nginx/"
}
variable "k8s_helm_ingress_nginx_chart_version" {
  type        = string
  description = "[ingress-nginx] chart version."
  default     = "4.4.0"
}
variable "k8s_helm_ingress_nginx_replica_count" {
  type        = number
  description = "[ingress-nginx] config replicas."
  default     = 3
}

#--- argocd + another config
variable "k8s_argocd_is_created" {
  type        = bool
  description = "Allow make argocd."
  default     = true
}
variable "k8s_namespace_argocd" {
  type        = string
  description = "ArgoCD target namespace deployment"
  default     = "argocd"
}
#argocd_repo_username
variable "k8s_argocd_repo_username" {
  type        = string
  description = "ArgoCD repo username"
}
#argocd_repo_password
variable "k8s_argocd_repo_password" {
  type        = string
  description = "ArgoCD repo password"
}


# k8s_ingress_class_name
variable "k8s_ingress_class_name" {
  type        = string
  description = "Ingress class name"
  default     = "nginx-dev"
}

variable "k8s_namespace_microservice" {
  type        = list(string)
  description = "List of namespaces deploy microservice unit."
}
variable "aws_route53_record_argocd_server" {
  type = object({
    name : string,
    type : string,
    evaluate_target_health : bool
  })
  description = "Config record argocd web server."
}
