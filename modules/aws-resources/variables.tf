variable "common_name_prefix" {
  type        = string
  description = "Name prefix (apply prefix name role config)"
}
variable "common_environment" {
  type        = string
  description = "Terraform name environment detected (current is development or production)"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "common_private_zone" {
  type        = string
  description = "Private Zone"
}
variable "vpc_private_subnets" {
  description = "List Private Subnet"
  type        = list(string)
}
variable "availability_zones" {
  description = "List Availability Zones"
  type        = list(string)
}

#region DocumentDB
variable "create_docdb" {
  type        = bool
  description = "Create DocumentDB"
  default     = false
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
  default     = "db.t3.medium"
}
#endregion

#region Redis
variable "create_redis" {
  type        = bool
  description = "Create Redis"
  default     = true
}
variable "redis_version" {
  type        = string
  description = "The version of Redis to use"
  default     = "7.0.5"
}
variable "redis_node_type" {
  type        = string
  description = "The compute and memory capacity of the nodes in the node group (shard)"
  default     = "cache.t3.micro"
}
variable "redis_num_node_groups" {
  type        = number
  description = "The number of node groups (shards) for this Redis replication group"
  default     = 3
}
variable "redis_replicas_per_node_group" {
  type        = number
  description = "The number of node groups (shards) for this Redis replication group"
  default     = 2
}
# redis_num_cache_clusters
variable "redis_num_cache_clusters" {
  type        = number
  description = "The number of cache clusters this replication group will have"
  default     = 2
}
# redis_maintenance_window
variable "redis_maintenance_window" {
  type        = string
  description = "The weekly time range (in UTC) during which maintenance on the cache cluster is performed"
  default     = "tue:04:00-tue:05:00"
}
# redis_snapshot_window
variable "redis_snapshot_window" {
  type        = string
  description = "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster"
  default     = "00:30-01:30"
}
# redis_snapshot_retention_limit
variable "redis_snapshot_retention_limit" {
  type        = number
  description = "The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them"
  default     = 7
}

variable "redis_parameter_group_name" {
  type        = string
  description = "The name of the parameter group to associate with this replication group"
  default     = "default.redis7.cluster.on"
}
#endregion

#region RabbitMQ
variable "create_rabbitmq" {
  type        = bool
  description = "Create RabbitMQ"
  default     = true
}
variable "awsmq_auto_minor_version_upgrade" {
  type        = bool
  description = "Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions"
  default     = false
}
variable "awsmq_deployment_mode" {
  type        = string
  description = "The deployment mode of the broker"
  default     = "CLUSTER_MULTI_AZ"
}
variable "awsmq_engine_version" {
  type        = string
  description = "The version of the broker engine. Note that when a broker is created, the EngineVersion parameter can't be changed"
  default     = "3.10.10"
}
variable "awsmq_host_instance_type" {
  type        = string
  description = "The broker's instance type"
  default     = "mq.m5.large"
}
variable "awsmq_publicly_accessible" {
  type        = bool
  description = "Whether to enable connections from applications outside of the VPC that hosts the broker's subnets"
  default     = false
}
variable "awsmq_apply_immediately" {
  type        = bool
  description = "Apply policy immediately"
  default     = true
}
variable "awsmq_maintenance_window_start_time" {
  type        = map(string)
  description = "The parameters that determine the WeeklyStartTime"
  default = {
    day_of_week = "WEDNESDAY"
    time_of_day = "07:00"
    time_zone   = "UTC"
  }
}
variable "awsmq_username" {
  type        = string
  description = "The username of the administrative user"
  default     = "rabbitmqadmin"
}
variable "awsmq_password" {
  type        = string
  description = "The password of the administrative user"
  default     = "rabbitmqadmin123@"
}
#endregion

#region Aurora PostgreSQL
variable "create_postgres" {
  type        = bool
  description = "Create Aurora Postgres"
  default     = true
}
variable "postgres_engine_version" {
  type        = string
  description = "The database engine version"
  default     = "13.7"
}
variable "postgres_username" {
  type        = string
  description = "The master username for the DB cluster"
  default     = "postgresqladmin"
}
variable "postgres_password" {
  type        = string
  description = "The master password for the DB cluster"
  default     = "postgresqladmin123"
}

variable "postgres_backup_window" {
  type        = string
  description = "The daily time range during which automated backups are created if they are enabled"
  default     = "07:01-07:31"
}
variable "postgres_backup_retention_period" {
  type        = number
  description = "The number of days for which automated backups are retained"
  default     = 7
}
variable "postgres_maintenance_window" {
  type        = string
  description = "The window to perform maintenance in"
  default     = "sun:05:00-sun:05:30"
}
variable "postgres_auto_minor_version_upgrade" {
  type        = bool
  description = "Enables automatic upgrades to new minor versions for postgreSQL"
  default     = false
}
variable "postgres_apply_immediately" {
  type        = bool
  description = "Enable strategy apply immediately"
  default     = true
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

variable "postgres_deletion_protection" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  default     = true
}
variable "postgres_skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB cluster snapshot is created before the DB cluster is deleted"
  default     = true
}

variable "postgres_cluster_instance_count" {
  type        = number
  description = "The number of instances in the DB cluster"
  default     = 2
}
variable "postgres_instance_class" {
  type        = string
  description = "The instance class to use"
  default     = "db.t3.medium"
}
#endregion