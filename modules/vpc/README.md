# VPC & Network

## <a name='TableofContents'></a>Table of Contents
<!-- vscode-markdown-toc -->
* [1. VPC](#VPC)
* [2. Network](#Network)
* [3. Resources](#Resources)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->


## <a name='VPC'></a>1. VPC

This module will create VPC with 3 public subnets and 3 private subnets. The public subnets will be used for bastion host, rancher, and other services that need to be accessed from the Internet. The private subnets will be used for application and database.

## <a name='Network'></a>2. Network

This will install the Route53 private hosted zone for the VPC. The private hosted zone will be used for the application and database in the VPC.

## <a name='Resources'></a>3. Resources
- VPC related resources
- Route53 private hosted zone `local.dentity.com`

