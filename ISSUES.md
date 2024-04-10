# List of issues and solutions

## Cluster autoscaler scale up nodegroup from 0

You should add the tag `k8s.io/cluster-autoscaler/node-template/label/${TAINT_KEY}`: ${TAIN_VALUE} to both nodegroup and ASG.

Example:

Gitlab runner: `k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/business: gitlab-runner`

## Unable to connect to the server: dial tcp localhost... when apply terraform

You should try switching the field name in data `aws_eks_cluster` and `aws_eks_cluster_auth` from data-source.tf 

```hcl
data "aws_eks_cluster" "cluster" {
  # name       = module.eks_cluster.cluster_name #dynamic name of cluster => used when first time create cluster
  name       = var.eks_config_cluster_name #fixed name of cluster
}
```

It happens when it try to read the configuration from the cluster, but the cluster is not ready yet (or sometimes, reading state is not right => terraform thought the cluster is not ready yet => need to config to the fixed value name of cluster)