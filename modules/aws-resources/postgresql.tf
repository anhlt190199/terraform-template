# create aws aurora postgresql cluster
resource "aws_db_subnet_group" "postgres_subnet_group" {
  count      = var.create_postgres ? 1 : 0
  name       = "${var.common_name_prefix}-postgres-subnet-group"
  subnet_ids = var.vpc_private_subnets
  tags = {
    Name = "${var.common_name_prefix}-postgres-subnet-group"
  }
}

# create security group for postgres allow all trafic
resource "aws_security_group" "postgres_sg" {
  count       = var.create_postgres ? 1 : 0
  name        = "${var.common_name_prefix}-postgres"
  description = "Allow inbound traffic from the VPC"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }

  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "Allow inbound traffic from the VPC"
  }

  tags = {
    Name = "${var.common_name_prefix}-postgres"
  }
}

# create postgres resource on aws
resource "aws_rds_cluster" "postgres_cluster" {
  count                           = var.create_postgres ? 1 : 0
  availability_zones              = var.availability_zones
  backup_retention_period         = var.postgres_backup_retention_period # 7 days
  cluster_identifier              = "${var.common_name_prefix}-postgres"
  db_cluster_parameter_group_name = "default.aurora-postgresql13"
  db_subnet_group_name            = aws_db_subnet_group.postgres_subnet_group[count.index].name
  engine                          = "aurora-postgresql"
  port                            = 5432
  master_username                 = var.postgres_username
  master_password                 = var.postgres_password
  preferred_backup_window         = var.postgres_backup_window      #"05:01-05:31"
  preferred_maintenance_window    = var.postgres_maintenance_window #"mon:00:00-mon:00:30"
  vpc_security_group_ids          = [aws_security_group.postgres_sg[count.index].id]
  storage_encrypted               = var.postgres_storage_encrypted #true
  #  kms_key_id = "arn:aws:kms:us-east-2:814793154525:key/ba68f990-e7ee-48c1-9b95-23df58c0bbc6"
  engine_version                      = var.postgres_engine_version                      #"13.7"
  iam_database_authentication_enabled = var.postgres_iam_database_authentication_enabled #false
  #  engine_mode = "provisioned"
  deletion_protection       = var.postgres_deletion_protection #true
  skip_final_snapshot       = var.postgres_skip_final_snapshot #true
  final_snapshot_identifier = "${var.common_name_prefix}-postgres-final-snapshot"

  depends_on = [aws_db_subnet_group.postgres_subnet_group]
}

# rds cluster instance
resource "aws_rds_cluster_instance" "postgres_cluster_instance" {
  count                      = var.create_postgres ? var.postgres_cluster_instance_count : 0
  identifier                 = "${var.common_name_prefix}-postgres-${count.index}"
  cluster_identifier         = aws_rds_cluster.postgres_cluster[0].id
  instance_class             = var.postgres_instance_class
  engine                     = "aurora-postgresql"
  engine_version             = var.postgres_engine_version #"13.7"
  auto_minor_version_upgrade = var.postgres_auto_minor_version_upgrade
  apply_immediately          = var.postgres_apply_immediately

  depends_on = [aws_rds_cluster.postgres_cluster]
}

# create record on route53 for cluster endpoint
resource "aws_route53_record" "postgres_cluster_endpoint" {
  count   = var.create_postgres ? 1 : 0
  zone_id = data.aws_route53_zone.commons.zone_id
  name    = "postgres"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_rds_cluster.postgres_cluster[count.index].endpoint]

  depends_on = [aws_rds_cluster.postgres_cluster[0]]
}

resource "aws_route53_record" "postgres_cluster_reader_endpoint" {
  count   = var.create_postgres ? 1 : 0
  zone_id = data.aws_route53_zone.commons.zone_id
  name    = "postgres-reader"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_rds_cluster.postgres_cluster[count.index].reader_endpoint]

  depends_on = [aws_rds_cluster.postgres_cluster[0]]
}
