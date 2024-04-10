# AWS Resources

This module is used to provision AWS resources for EKS cluster.

## <a name='TableofContents'></a>Table of Contents
<!-- vscode-markdown-toc -->
* [Table of Contents](#TableofContents)
* [1. Resources](#Resources)
* [2. Infrastructure](#Infrastructure)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## <a name='Resources'></a>1. Resources
- Amazon MQ
- Amazon RDS Aurora Postgres
- Elasticache Redis
- DocumentDB (Change to MongoDB atlas due to the difference in the functionality of the MongoDB driver)

## <a name='Infrastructure'></a>2. Infrastructure

All the resources are provisioned in private network. You need to setup VPN to access to private network.

Only the application in the VPC can access the database resources. The application in the VPC can access the database resources through the VPC endpoint.