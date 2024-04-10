locals {
  #  new_eks_managed_node_groups add new subnet_ids to green and yellow and remove subnet_type
  # eks_managed_node_groups = {
  #   for groupkey, groupvalue in var.eks_managed_node_groups : "${var.eks_config_cluster_name}-${groupkey}" => merge({
  #     for k, v in groupvalue :
  #     k => v if k != "subnet_type"
  #   }, { subnet_ids = groupvalue.subnet_type == "public" ? try([module.vpc.public_subnets[groupvalue.subnet_index]], module.vpc.public_subnets) : try([module.vpc.private_subnets[groupvalue.subnet_index]], module.vpc.private_subnets) })
  # }
  #add more subnet


    eks_managed_node_groups = {
    for groupkey, groupvalue in var.eks_managed_node_groups : "${var.eks_config_cluster_name}-${groupkey}" => merge({
      for k, v in groupvalue :
      k => v if k != "subnet_type"
    }, {
        subnet_ids = (
  groupvalue.subnet_type == "public" ?
    try([module.vpc.public_subnets[groupvalue.subnet_index]], module.vpc.public_subnets) :

  (
  groupvalue.subnet_type == "private" ?
    try([module.vpc.private_subnets[groupvalue.subnet_index]], [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]) :
  (
  groupvalue.subnet_type == "production" ?
    try([module.vpc.private_subnets[4], module.vpc.private_subnets[5], module.vpc.private_subnets[6]]) :
    [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]

  )
  )
)
      })
  }
}