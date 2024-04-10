#--- user mapping
variable "common_name_prefix" {
  type        = string
  description = "Name prefix (apply prefix name role config)"
}
variable "common_aws_caller_identity" {
  type        = string
  description = "ID Account AWS"
}
#--- vpc
variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}
variable "vpc_private_subnets" {
  description = "List Private Subnet"
  type        = list(string)
}

#common_private_zone
variable "common_private_zone" {
  type        = string
  description = "Private Zone"
}

#vpn_security_group_id
variable "vpn_security_group_id" {
  type        = string
  description = "The ID of the security group to assign to the network interface"
}

#--- iam assumable_role
variable "iam_admin_users" {
  type        = list(string)
  description = "List of AWS User apply User admin kubernetes."
}
variable "iam_developer_users" {
  type        = list(string)
  description = "List of AWS User apply User developer kubernetes."
}
variable "iam_admin_roles" {
  type        = list(string)
  description = "List of AWS Role apply User admin kubernetes."
}
variable "iam_developer_roles" {
  type        = list(string)
  description = "List of AWS Role apply User developer kubernetes."
}
variable "iam_cluster_oidc_issuer_url" {
  type        = string
  description = "EKS cluster oidc issuer url."
}

#--- eks-common variables
variable "eks_config_cluster_name" {
  type        = string
  description = "EKS cluster name."
}
variable "eks_config_cluster_version" {
  type        = string
  description = "EKS cluster version (kubernetes version)."
}
variable "eks_config_cluster_environment" {
  type        = string
  description = "EKS cluster environment."
}
#variable "eks_config_write_kubeconfig" {
#  type        = bool
#  description = "EKS cluster write config."
#}
#variable "eks_config_write_path" {
#  type        = string
#  description = "EKS cluster write kube config path."
#}
variable "eks_config_enable_irsa" {
  type        = bool
  description = "EKS config irsa => apply config cluster-autoscaler."
}
#variable "eks_config_worker_ami_owner_id" {
#  type        = string
#  description = "EKS config worker ami owner (popular is amazon)."
#}
#variable "eks_config_worker_ami_name_filter" {
#  type        = string
#  description = "EKS config worker ami name (select ami with ref: https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html)."
#}
variable "eks_config_manage_aws_auth_configmap" {
  type        = bool
  description = "EKS config aws auth manager."
}
#eks_config_create_aws_auth_configmap
variable "eks_config_create_aws_auth_configmap" {
  type        = bool
  description = "EKS config aws auth configmap."
}

# eks_managed_node_groups

variable "eks_managed_node_groups" {
  type        = any
  description = "EKS config managed node groups."
}

#variable "eks_config_worker_groups_launch_template" {
#  type        = any
#  description = "EKS config list node group build in cluster"
#}

###############################################################################################
###############################################################################################
#--- helm spot handler
#k8s_config_enable_spot_termination_handler
variable "k8s_config_enable_spot_termination_handler" {
  type        = bool
  description = "Enable spot termination handler."
  default     = true
}
variable "k8s_helm_spot_termination_handler_name" {
  type        = string
  description = "K8S Spot termination handler release name."
  default     = "aws-node-termination-handler"
}
variable "k8s_helm_spot_termination_handler_chart_name" {
  type        = string
  description = "K8S Spot termination handler Helm chart name."
  default     = "aws-node-termination-handler"
}
variable "k8s_helm_spot_termination_handler_chart_repo" {
  type        = string
  description = "K8S Spot termination handler Helm repository name."
  default     = "https://aws.github.io/eks-charts"
}
variable "k8s_helm_spot_termination_handler_chart_version" {
  type        = string
  description = "K8S Spot termination handler Helm chart version."
  #  optional
  default = null
}
variable "k8s_helm_spot_termination_handler_chart_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy EKS Spot termination handler Helm chart."
  default     = "kube-system"
}

#--- helm metric server
#k8s_config_enable_metric_server
variable "k8s_config_enable_metric_server" {
  type        = bool
  description = "Enable metric server."
  default     = true
}
variable "k8s_helm_metric_server_handler_name" {
  type        = string
  description = "K8S metric server handler release name."
  default     = "metrics-server"
}
variable "k8s_helm_metric_server_handler_chart_name" {
  type        = string
  description = "K8S metric server handler Helm chart name."
  default     = "metrics-server"
}
variable "k8s_helm_metric_server_handler_chart_repo" {
  type        = string
  description = "K8S metric server handler Helm repository name."
  default     = "https://kubernetes-sigs.github.io/metrics-server"
}
variable "k8s_helm_metric_server_handler_chart_version" {
  type        = string
  description = "K8S metric server Helm chart version."
  default     = null
}
variable "k8s_helm_metric_server_handler_chart_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy metric server Helm chart."
  default     = "kube-system"
}

#--- helm autoscaler handler
#k8s_config_enable_cluster_autoscaler
variable "k8s_config_enable_cluster_autoscaler" {
  type        = bool
  description = "Enable cluster autoscaler."
  default     = true
}
variable "k8s_helm_autoscaler_handler_name" {
  type        = string
  description = "K8S autoscaler release name."
  default     = "cluster-autoscaler"
}
variable "k8s_helm_autoscaler_handler_chart_name" {
  type        = string
  description = "K8S autoscaler handler Helm chart name."
  default     = "cluster-autoscaler"
}
variable "k8s_helm_autoscaler_handler_chart_repo" {
  type        = string
  description = "K8S autoscaler handler Helm repository name."
  default     = "https://kubernetes.github.io/autoscaler"
}
variable "k8s_helm_autoscaler_handler_chart_version" {
  type        = string
  description = "K8S autoscaler Helm chart version."
  default     = "9.23.0"
}
variable "k8s_helm_autoscaler_handler_chart_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy autoscaler Helm chart."
  default     = "kube-system"
}

# helm coredns
#k8s_config_enable_core_dns
variable "k8s_config_enable_core_dns" {
  type        = bool
  description = "Enable core dns."
  default     = true
}
#k8s_helm_core_dns_name
variable "k8s_helm_core_dns_name" {
  type        = string
  description = "K8S CoreDNS release name."
  default     = "coredns"
}
#k8s_helm_core_dns_chart_name
variable "k8s_helm_core_dns_chart_name" {
  type        = string
  description = "K8S CoreDNS Helm chart name."
  default     = "coredns"
}
#k8s_helm_core_dns_chart_repo
variable "k8s_helm_core_dns_chart_repo" {
  type        = string
  description = "K8S CoreDNS Helm repository name."
  default     = "https://coredns.github.io/helm"
}
#k8s_helm_core_dns_chart_version
variable "k8s_helm_core_dns_chart_version" {
  type        = string
  description = "K8S CoreDNS Helm chart version."
  default     = null
}
#k8s_helm_core_dns_chart_namespace
variable "k8s_helm_core_dns_chart_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy CoreDNS Helm chart."
  default     = "kube-system"
}
#k8s_config_core_dns_tolerations
variable "k8s_config_core_dns_tolerations" {
  type        = any
  description = "K8S CoreDNS tolerations."
  default     = []
}
#k8s_config_core_dns_node_selector
variable "k8s_config_core_dns_node_selector" {
  type        = any
  description = "K8S CoreDNS node selector."
  default     = {}
}


# vpc_cni irsa vpc_cni_role_arn
variable "vpc_cni_role_arn" {
  type        = string
  description = "VPC CNI IRSA"
  default     = null
}
###############################################################################################
###############################################################################################