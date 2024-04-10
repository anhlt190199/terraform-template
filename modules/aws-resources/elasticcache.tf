## create elastic cache
#
## create elastic cache db subnet
resource "aws_elasticache_subnet_group" "redis" {
  count      = var.create_redis ? 1 : 0
  name       = "${var.common_name_prefix}-redis"
  subnet_ids = var.vpc_private_subnets
  tags = {
    Name = "${var.common_name_prefix}-redis"
  }
}
# create security group for elastic cache to self
resource "aws_security_group" "redis" {
  count       = var.create_redis ? 1 : 0
  name        = "${var.common_name_prefix}-redis"
  description = "Allow redis traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }

  ingress {
    from_port   = 6379
    protocol    = "tcp"
    to_port     = 6379
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "Allow redis traffic from VPC"
  }

  tags = {
    Name = "${var.common_name_prefix}-redis"
  }

  depends_on = [aws_elasticache_subnet_group.redis]
}

# create replication_group_id redis cluster
resource "aws_elasticache_replication_group" "redis" {
  count = var.create_redis ? 1 : 0
  # replication_group_id       = "${var.common_name_prefix}-redis"
  replication_group_id = "anhlt-main-single-redis"
  # description                = "${var.common_name_prefix} Redis single"
  description = "anhlt-main-single-redis"
  node_type   = var.redis_node_type
  # num_node_groups            = var.redis_num_node_groups
  # replicas_per_node_group    = var.redis_replicas_per_node_group
  num_cache_clusters         = var.redis_num_cache_clusters
  engine                     = "redis"
  engine_version             = var.redis_version
  parameter_group_name       = var.redis_parameter_group_name
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.redis[count.index].name
  security_group_ids         = [aws_security_group.redis[count.index].id]
  automatic_failover_enabled = true
  maintenance_window         = var.redis_maintenance_window
  snapshot_window            = var.redis_snapshot_window
  snapshot_retention_limit   = var.redis_snapshot_retention_limit
  apply_immediately          = false
  transit_encryption_enabled = false
  at_rest_encryption_enabled = false
  auto_minor_version_upgrade = false
  multi_az_enabled           = true
  # tags = {
  #   # Name = "${var.common_name_prefix}-redis"
  #   Name = "anhlt-main-single-redis"
  # }

  depends_on = [aws_elasticache_subnet_group.redis]
}

## create elastic cache redis cluster
#resource "aws_elasticache_cluster" "redis" {
#  cluster_id           = "${var.common_name_prefix}-redis"
#  replication_group_id = aws_elasticache_replication_group.redis.id
#  tags = {
#    Name = "${var.common_name_prefix}-redis"
#  }
#  depends_on = [aws_elasticache_subnet_group.redis]
#}

# create record set for elastic cache redis cluster
# resource "aws_route53_record" "redis" {
#   count   = var.create_redis ? 1 : 0
#   zone_id = data.aws_route53_zone.commons.zone_id
#   name    = "redis"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_elasticache_replication_group.redis[count.index].configuration_endpoint_address]

#   depends_on = [aws_elasticache_replication_group.redis]
# }