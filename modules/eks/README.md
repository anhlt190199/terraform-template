# EKS Module

## <a name='TableofContents'></a>Table of Contents
<!-- vscode-markdown-toc -->
* [1. Requirements](#Requirements)
* [2. Resources](#Resources)
	* [2.1 EKS cluster resources](#EKSclusterresources)
	* [2.2 Assume roles for EKS cluster](#AssumerolesforEKScluster)
	* [2.3 EKS cluster addons](#EKSclusteraddons)
	* [2.4 Main resources for EKS cluster](#MainresourcesforEKScluster)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## <a name='Requirements'></a>1. Requirements

- VPN

## <a name='Resources'></a>2. Resources
### <a name='EKSclusterresources'></a>2.1 EKS cluster resources

This will use aws module EKS to create EKS cluster. All the configuration for EKS cluster is in module eks.

### <a name='AssumerolesforEKScluster'></a>2.2 Assume roles for EKS cluster

The IAM assume role is used to allow the EKS cluster to access other AWS resources. The IAM assume role is created in the `irsa.tf`

List irsa:
- `cluster-autoscaler`: allow cluster autoscaler to access to EKS cluster to scale up/down nodes.
- `external-dns`: allow external-dns to access to Route53 to create/update/delete DNS records.
- `alb-controller`: allow alb-controller to access to EKS cluster to create/update/delete ALB.
- `gitlab-runner`: allow gitlab-runner to access s3 bucket to cache docker images and pull/push docker images to ECR.
- `vault-kms`: allow vault to access to KMS to encrypt/decrypt secrets.

### <a name='EKSclusteraddons'></a>2.3 EKS cluster addons

Addons for EKS cluster is created in `addons.tf`.

List addons:
- `kube-proxy`: this is default addon for EKS cluster.
- `vpc-cni`: this is default addon for EKS cluster.
- `aws-ebs-csi-driver`: this is addon for EKS cluster to manage EBS volumes.
- `coredns`: this is default addon for EKS cluster. Note that coredns addon does not support taint/toletration, only support nodeSelector. So we need to **create a default node group for coredns**.

### <a name='MainresourcesforEKScluster'></a>2.4 Main resources for EKS cluster

This is main resources for EKS cluster. This will create:

- `Spot termination handler`: this is daemonset to handle spot termination.
- `Metrics server`: this is deployment to collect metrics from EKS cluster.
- ... 