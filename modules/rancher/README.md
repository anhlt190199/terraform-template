# Create Rancher

## <a name='TableofContents'></a>Table of Contents
<!-- vscode-markdown-toc -->
* [1. Requirements](#Requirements)
* [2. Resources](#Resources)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

This module will create Rancer

## <a name='Requirements'></a>1. Requirements
- AMI with tag `AmiType: rancher` (you can build AMI with packer from [here](../../packer/README.md)). This will use AMI that contains Rancher deployed by docker-compose.

## <a name='Resources'></a>2. Resources
- EC2 to run rancher
- Security group for EC2
- Elastic IP for EC2
- Route53 record for EC2