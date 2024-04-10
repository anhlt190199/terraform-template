data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

#data "aws_lbs" "alb_arns" {
#  tags = {
#    "elbv2.k8s.aws/cluster"    = module.eks.cluster_name
#    "ingress.k8s.aws/resource" = "LoadBalancer"
#  }
#  depends_on = [module.eks]
#}

#data "aws_lb" "alb" {
#  count = length(data.aws_lbs.alb_arns.arns)
#  arn   = tolist(data.aws_lbs.alb_arns.arns)[count.index]
#  depends_on = [data.aws_lbs.alb_arns.arns]
#}

data "aws_lb" "alb" {
  count = length(var.alb_business)
  tags = {
    "elbv2.k8s.aws/cluster"    = module.eks.cluster_name
    "ingress.k8s.aws/resource" = "LoadBalancer"
    "alb-business"             = var.alb_business[count.index]
  }
  # depends_on = [module.eks]
}
