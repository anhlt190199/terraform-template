#output "cluster_id" {
##  value       = module.eks_cluster.cluster_id
#  value       = module.eks_cluster.cluster_name
#  description = "The VPC ID"
#}

output "cluster_oidc_issuer_url" {
  value       = module.eks_cluster.cluster_oidc_issuer_url
  description = "The OIDC issuer url"
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks_cluster.oidc_provider_arn
}

# module.eks_cluster.cluster_name
output "cluster_name" {
  value       = module.eks_cluster.cluster_name
  description = "The name of the cluster"
}

#node_security_group_id
output "node_security_group_id" {
  value       = module.eks_cluster.node_security_group_id
  description = "The security group ID of the EKS cluster"
}
#primary_security_group_id
output "cluster_security_group_id" {
  value       = module.eks_cluster.cluster_security_group_id
  description = "The security group ID of the cluster"
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks_cluster.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks_cluster.cluster_id
}
#output "kubeconfig_filename" {
#  value       = module.eks_cluster.kubeconfig_filename
#  description = "The filename of the generated kubectl config. Will block on cluster creation until the cluster is really ready."
#}