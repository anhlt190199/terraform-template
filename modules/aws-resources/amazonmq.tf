## create amazonmq
# create security group for elastic cache to self
resource "aws_security_group" "rabbitmq" {
  count       = var.create_rabbitmq ? 1 : 0
  name        = "${var.common_name_prefix}-rabbitmq"
  description = "Allow rabbitmq traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }

  ingress {
    from_port   = 5671
    protocol    = "tcp"
    to_port     = 5671
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "Allow rabbitmq traffic from VPC"
  }

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "Allow redis traffic from VPC"
  }

  #TODO: remove after destroy old infras
  ingress {
    from_port   = 5671
    protocol    = "tcp"
    to_port     = 5671
    cidr_blocks = ["172.35.0.0/16"]
    description = "Allow redis traffic from VPC"
  }

  tags = {
    Name = "${var.common_name_prefix}-rabbitmq"
  }
}

resource "aws_mq_broker" "rabbitmq" {
  count       = var.create_rabbitmq ? 1 : 0
  broker_name = "${var.common_name_prefix}-rabbitmq"

  auto_minor_version_upgrade = var.awsmq_auto_minor_version_upgrade # default false
  deployment_mode            = var.awsmq_deployment_mode            # CLUSTER_MULTI_AZ
  engine_type                = "RabbitMQ"
  engine_version             = var.awsmq_engine_version     # 3.10.10
  host_instance_type         = var.awsmq_host_instance_type # mq.m5.large
  storage_type               = "ebs"
  security_groups            = [aws_security_group.rabbitmq[count.index].id]
  publicly_accessible        = var.awsmq_publicly_accessible # default false
  subnet_ids                 = var.vpc_private_subnets
  apply_immediately          = true

  user {
    username = var.awsmq_username
    password = var.awsmq_password
  }
  #{
  #  day_of_week = "SUN"
  #  time_of_day = "02:00"
  #  time_zone   = "UTC"
  #}
  maintenance_window_start_time {
    day_of_week = var.awsmq_maintenance_window_start_time.day_of_week
    time_of_day = var.awsmq_maintenance_window_start_time.time_of_day
    time_zone   = var.awsmq_maintenance_window_start_time.time_zone
  }
  authentication_strategy = "simple"
  depends_on              = [aws_security_group.rabbitmq]

}
