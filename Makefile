quality:
	pre-commit run -a

# role: devops
plan-development:
	terraform plan -var-file "development.tfvars"

deploy-vpn:
	terraform apply -target=module.vpc -target=module.vpn -var-file=development.tfvars
	#terraform apply -target=module.vpc -target=module.eks -var-file=development.tfvars

deploy-development:
	terraform apply -var-file 'development.tfvars'

output-kubeconfig:
	aws eks update-kubeconfig --name anhlt-main-cluster

# STEP PROVISIONING ==========================================================
#region: Provisioning
# create all AMI (optional because we have already created AMI)
deploy-phase-0:
	make create-ami-vpn
	make create-ami-database
	make create-ami-rancher

# create VPC and VPN
deploy-phase-1:
	terraform apply -target=module.vpc -target=module.vpn -var-file=development.tfvars

# create all other resources but CloudFront (because cloudfront needs to be created after the creation of ALB which is created by the deployment of the EKS cluster)
deploy-phase-2:
	terraform apply -var-file 'development.tfvars'

# create CloudFront
deploy-phase-3:
	# the same command as phase 2 because the terraform code automatically detect the ALB and create the CloudFront
	terraform apply -var-file 'development.tfvars'
#endregion

# STEP DESTROYING ==========================================================
#region: Destroying
# destroy all resources
destroy-all:
	terraform destroy -var-file 'development.tfvars'

# destroy all resources except VPC and VPN


create-ami-vpn:
	packer build packer/vpn.json

create-ami-database:
	packer build packer/database.json

create-ami-rancher:
	packer build packer/rancher.json