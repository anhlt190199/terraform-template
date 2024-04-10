# create aws db subnet group
resource "aws_docdb_subnet_group" "docb_subnet_group" {
  count      = var.create_docdb ? 1 : 0
  name       = "${var.common_name_prefix}-docdb-subnet-group"
  subnet_ids = var.vpc_private_subnets
  tags = {
    Name = "${var.common_name_prefix}-docdb-subnet-group"
  }
}

# create security group for docdb allow all trafic
resource "aws_security_group" "docdb_sg" {
  count       = var.create_docdb ? 1 : 0
  name        = "${var.common_name_prefix}-docdb"
  description = "Allow inbound traffic from the VPC"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }

  ingress {
    from_port   = 27017
    protocol    = "tcp"
    to_port     = 27017
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "Allow redis traffic from VPC"
  }

  tags = {
    Name = "${var.common_name_prefix}-docdb"
  }
}

resource "aws_docdb_cluster_parameter_group" "docdb_cluster_parameter_group" {
  count  = var.create_docdb ? 1 : 0
  name   = "${var.common_name_prefix}-docdb-parameter-group"
  family = var.docdb_family
  parameter {
    name  = "tls"
    value = "disabled"
  }
}

# create documentdb resource on aws
resource "aws_docdb_cluster" "docdb_cluster" {
  count                           = var.create_docdb ? 1 : 0
  cluster_identifier              = "${var.common_name_prefix}-docdb-cluster"
  availability_zones              = var.availability_zones
  master_username                 = var.docdb_master_username
  master_password                 = var.docdb_master_password
  engine_version                  = var.docdb_engine_version
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.docdb_cluster_parameter_group[count.index].name
  backup_retention_period         = 5
  preferred_backup_window         = "07:00-09:00"
  preferred_maintenance_window    = "sun:05:00-sun:06:00"
  skip_final_snapshot             = true
  storage_encrypted               = false
  db_subnet_group_name            = aws_docdb_subnet_group.docb_subnet_group[count.index].name
  vpc_security_group_ids          = [aws_security_group.docdb_sg[count.index].id]

  depends_on = [aws_docdb_subnet_group.docb_subnet_group[0]]
}

resource "aws_docdb_cluster_instance" "docdb_cluster_instance" {
  count              = var.create_docdb ? var.docdb_instance_num : 0
  identifier         = "${var.common_name_prefix}-docdb-cluster-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb_cluster[0].id
  instance_class     = var.docdb_instance_class
  #  preferred_maintenance_window = "thu:07:19-thu:07:49"
  # engine_version = "4.0.0"
  auto_minor_version_upgrade = true
  apply_immediately          = true

  depends_on = [aws_docdb_cluster.docdb_cluster[0]]
}

# create record on route53 for cluster endpoint
# documentdb.${var.common_environment}.${var.common_private_zone}
resource "aws_route53_record" "docdb_cluster_endpoint" {
  count   = var.create_docdb ? 1 : 0
  zone_id = data.aws_route53_zone.commons.zone_id
  name    = "documentdb"
  type    = "CNAME"
  ttl     = "300"
  # TODO: need edit
  records = [aws_docdb_cluster.docdb_cluster[count.index].endpoint]

  depends_on = [aws_docdb_cluster.docdb_cluster[0]]
}

resource "aws_route53_record" "docdb_cluster_reader_endpoint" {
  count   = var.create_docdb ? 1 : 0
  zone_id = data.aws_route53_zone.commons.zone_id
  name    = "documentdb-reader"
  type    = "CNAME"
  ttl     = "300"
  # TODO: need edit
  records = [aws_docdb_cluster.docdb_cluster[count.index].reader_endpoint]

  depends_on = [aws_docdb_cluster.docdb_cluster[0]]
}
