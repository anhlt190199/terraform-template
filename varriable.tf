#--- provider variables
# cloudflare_api_token
variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
}

#--- common variable
variable "common_prefix" {
  type        = string
  description = "Terraform name prefix detected (current is dev or prod)."
}
variable "common_environment" {
  type        = string
  description = "Terraform name environment detected (current is development or production)."
}
variable "common_mail_devops" {
  type        = string
  description = "Mail devops team"
}
variable "common_domain_name" {
  type        = string
  description = "Primary domain (selected from hosted zone)."
}
#certificate_domain
variable "certificate_domain" {
  type        = string
  description = "Certificate domain (selected from hosted zone)."
}
variable "common_private_zone" {
  type        = string
  description = "Private zone name."
}
variable "create_private_zone" {
  type        = bool
  description = "Create private zone."
  default     = true
}

#region module vpc ====================================================
variable "vpc_main_network_block" {
  type        = string
  description = "Base CIDR block to be used in our VPC."
}
variable "vpc_subnet_prefix_extension" {
  type        = number
  description = "CIDR block bits extension to calculate CIDR blocks of each subnetwork."
}

variable "vpc_zone_offset" {
  type        = number
  description = "CIDR block bits extension offset to calculate Public subnets, avoiding collisions with Private subnets."
}
#endregion

#region module vpn ====================================================
variable "vpn_instance_type" {
  type        = string
  description = "VPN instance type."
}
#endregion

#region module eks ====================================================
variable "eks_config_cluster_name" {
  type        = string
  description = "EKS cluster name."
}
#eks_config_cluster_version
variable "eks_config_cluster_version" {
  type        = string
  description = "EKS cluster version."
}
# eks_managed_node_groups
variable "eks_managed_node_groups" {
  type        = any
  description = "EKS managed node groups."
}

#--- iam assumable_role
variable "iam_admin_users" {
  type        = list(string)
  description = "List of AWS User apply User admin kubernetes."
}
variable "iam_developer_users" {
  type        = list(string)
  description = "List of AWS User apply User developer kubernetes."
}
variable "iam_admin_roles" {
  type        = list(string)
  description = "List of AWS Role apply User admin kubernetes."
}
variable "iam_developer_roles" {
  type        = list(string)
  description = "List of AWS Role apply User developer kubernetes."
}

variable "eks_config_manage_aws_auth_configmap" {
  type        = bool
  description = "EKS config aws auth manager."
}
#eks_config_create_aws_auth_configmap
variable "eks_config_create_aws_auth_configmap" {
  type        = bool
  description = "EKS config aws auth configmap."
}
variable "eks_config_enable_irsa" {
  type        = bool
  description = "EKS config irsa => apply config cluster-autoscaler."
}
#k8s_config_core_dns_node_selector
#k8s_config_core_dns_tolerations
variable "k8s_config_core_dns_node_selector" {
  type        = any
  description = "Kubernetes config core dns node selector."
  default     = {}
}
variable "k8s_config_core_dns_tolerations" {
  type        = any
  description = "Kubernetes config core dns tolerations."
  default     = []
}

#endregion

#region module k8s-resource ===========================================
variable "k8s_namespace_microservice" {
  type        = list(string)
  description = "Kubernetes microservice namespace."
}
variable "aws_route53_record_argocd_server" {
  type        = map(string)
  description = "AWS Route53 record argocd server."
}
#k8s_argocd_repo_username
variable "k8s_argocd_repo_username" {
  type        = string
  description = "Kubernetes argocd repo username."
}
#k8s_argocd_repo_password
variable "k8s_argocd_repo_password" {
  type        = string
  description = "Kubernetes argocd repo password."
}
#endregion

#region module dev-database ==========================================
# dev_database_instance_type
variable "dev_database_instance_type" {
  type        = string
  description = "Database instance type."
}

variable "dev_mongodb7_instance_type" {
  type        = string
  description = "Database instance type."
}

#endregion

#region rancher ======================================================
#rancher_instance_type
variable "rancher_instance_type" {
  type        = string
  description = "Rancher instance type."
}

#region module aws-resources ==========================================

#--- documentdb
#create_docdb
variable "create_docdb" {
  type        = bool
  description = "Create DocumentDB"
  default     = true
}
variable "docdb_instance_num" {
  type        = number
  description = "Number of DocumentDB instances"
  default     = 3
}
#docdb_family
variable "docdb_family" {
  type        = string
  description = "DocumentDB family"
  default     = "docdb5.0"
}

variable "docdb_engine_version" {
  type        = string
  description = "DocumentDB engine version."
  default     = "5.0.0"
}
variable "docdb_master_username" {
  type        = string
  description = "The master username for the DB cluster"
  default     = "admin"
}
variable "docdb_master_password" {
  type        = string
  description = "The master password for the DB cluster"
  default     = "admin123"
}
variable "docdb_instance_class" {
  type        = string
  description = "The instance class to use"
  default     = "db.r5.large"
}
variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group ids to be associated with the DB cluster"
  default     = []
}

#--- redis
# create_redis
variable "create_redis" {
  type        = bool
  description = "Create Redis"
  default     = true
}
# redis_version
variable "redis_version" {
  type        = string
  description = "The version of Redis to use"
  default     = "5.0.6"
}
# redis_node_type
variable "redis_node_type" {
  type        = string
  description = "The compute and memory capacity of the nodes in the node group (shard)"
  default     = "cache.t3.micro"
}
# num_redis_nodes
variable "redis_num_node_groups" {
  type        = number
  description = "The number of node groups (shards) for this Redis replication group"
  default     = 1
}
# redis_replicas_per_node_group
variable "redis_replicas_per_node_group" {
  type        = number
  description = "The number of replica nodes in each node group (shard)"
  default     = 1
}
# redis_num_cache_clusters
variable "redis_num_cache_clusters" {
  type        = number
  description = "The number of cache clusters this replication group will have"
  default     = 2
}
# redis_parameter_group_name
variable "redis_parameter_group_name" {
  type        = string
  description = "The name of the parameter group to associate with this replication group"
  default     = "default.redis5.0"
}

#--- rabbitmq
#create_rabbitmq
variable "create_rabbitmq" {
  type        = bool
  description = "Create RabbitMQ"
  default     = true
}
#awsmq_auto_minor_version_upgrade
variable "awsmq_auto_minor_version_upgrade" {
  type        = bool
  description = "Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions"
  default     = true
}
#awsmq_deployment_mode
variable "awsmq_deployment_mode" {
  type        = string
  description = "The deployment mode of the broker"
  default     = "CLUSTER_MULTI_AZ"
}
#awsmq_engine_version
variable "awsmq_engine_version" {
  type        = string
  description = "The version of the broker engine. Note that when a broker is created, the EngineVersion parameter can't be changed"
  default     = "3.10.10"
}
#awsmq_host_instance_type
variable "awsmq_host_instance_type" {
  type        = string
  description = "The broker's instance type"
  default     = "mq.m5.large"
}
#awsmq_publicly_accessible
variable "awsmq_publicly_accessible" {
  type        = bool
  description = "Whether to enable connections from applications outside of the VPC that hosts the broker's subnets"
  default     = false
}
#awsmq_maintenance_window_start_time
#default
#{
#  day_of_week = "SUN"
#  time_of_day = "02:00"
#  time_zone   = "UTC"
#}
variable "awsmq_maintenance_window_start_time" {
  type        = map(string)
  description = "The parameters that determine the WeeklyStartTime"
  default = {
    day_of_week = "SUNDAY"
    time_of_day = "00:00"
    time_zone   = "UTC"
  }
}
#awsmq_username
variable "awsmq_username" {
  type        = string
  description = "The username of the administrative user"
  default     = "rabbitmqadmin"
}
#awsmq_password
variable "awsmq_password" {
  type        = string
  description = "The password of the administrative user"
  default     = "rabbitmqadmin123@"
}

#--- aws aurora postgres
# create_postgres
variable "create_postgres" {
  type        = bool
  description = "Create Aurora Postgres"
  default     = true
}
# postgres_engine_version
variable "postgres_engine_version" {
  type        = string
  description = "The database engine version"
  default     = "13.7"
}
# postgres_username
variable "postgres_username" {
  type        = string
  description = "The master username for the DB cluster"
  default     = "postgresqladmin"
}
# postgres_password
variable "postgres_password" {
  type        = string
  description = "The master password for the DB cluster"
  default     = "postgresqladmin123"
}

#postgres_backup_window
variable "postgres_backup_window" {
  type        = string
  description = "The daily time range during which automated backups are created if they are enabled"
  default     = "07:01-07:31"
}

# postgres_backup_retention_period
variable "postgres_backup_retention_period" {
  type        = number
  description = "The number of days for which automated backups are retained"
  default     = 7
}
# postgres_maintenance_window
variable "postgres_maintenance_window" {
  type        = string
  description = "The window to perform maintenance in"
  default     = "sun:05:00-sun:05:30"
}

# postgres_storage_encrypted
variable "postgres_storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB cluster is encrypted"
  default     = true
}

# postgres_iam_database_authentication_enabled
variable "postgres_iam_database_authentication_enabled" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  default     = false
}

# postgres_deletion_protection
variable "postgres_deletion_protection" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  default     = true
}

# postgres_cluster_instance_count
variable "postgres_cluster_instance_count" {
  type        = number
  description = "The number of instances in the DB cluster"
  default     = 2
}

# postgres_instance_class
variable "postgres_instance_class" {
  type        = string
  description = "The instance class to use"
  default     = "db.t3.medium"
}

#endregion

#region --- aws waf
#create_web_acl_association
variable "create_web_acl_association" {
  type        = bool
  description = "Create ALB Association"
  default     = true
}

#region Cloudfront
#alb_business
variable "alb_business" {
  type        = list(string)
  description = "The name of the ALB Business"
}

variable "cloudfront" {
  type        = map(any)
  description = "The configuration for AWS Cloudfront"
}

#region AutomationWAF
# variable "waf_config" {
#   type = any
#   description = "WAF Config"
# }

#endregion
#ecr_alert
variable "ecr_alert" {
  type        = map(any)
  description = "The configuration for ECR alert vulnerability"
}

variable "mongodb_instances" {
  type        = map(any)
  description = "The configuration for EC2 mongodb instances"
}
#ebs
variable "dev_database_availability_zone" {
  type = string
}

variable "dev_database_volume_type" {
  type = string
}

variable "dev_database_volume_iops" {
  type = number
}

variable "dev_database_volume_size" {
  type = number
}