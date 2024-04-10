locals {
  common_tls_name = "www.dentity.com"
  namespaces_config_cert = concat(var.k8s_namespace_microservice, [
    var.k8s_namespace_argocd,
    var.k8s_namespace_ingress_nginx,
  ])
}