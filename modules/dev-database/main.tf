resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.eks_config_cluster_name}-dev-database-kp"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${aws_key_pair.deployer.key_name}.pem"
  content         = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

resource "aws_security_group" "sg_dev_database" {
  name        = "sg_dev_database"
  description = "allow connect to internet"
  vpc_id      = var.vpc_id

  #    ingress port 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }
  #  ingress for mongodb
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "mongodb"
  }

  ingress {
    from_port   = 27018
    to_port     = 27018
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "mongodb7"
  }

  #ingress for postgres
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "postgres"
  }

  #ingress for redis
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "redis"
  }

  #ingress for rabbitmq
  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "rabbitmq dev"
  }

  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "rabbitmq management dev"
  }

  #ingress for rabbitmq
  ingress {
    from_port   = 5673
    to_port     = 5673
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "rabbitmq staging"
  }

  ingress {
    from_port   = 15673
    to_port     = 15673
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "rabbitmq management staging"
  }

  # portainer (i don't know who provision this, but it's here to match current state)
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "manual-portainer"
  }

  ingress {
    from_port   = 9443
    to_port     = 9443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "manual-portainer"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.eks_config_cluster_name}-dev-database-sg"
  }
}

resource "aws_instance" "database" {
  associate_public_ip_address = true
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = aws_key_pair.deployer.key_name
  ami                         = data.aws_ami.ami.id
  vpc_security_group_ids      = [aws_security_group.sg_dev_database.id]
  iam_instance_profile        = "${var.eks_config_cluster_name}-ssm-instance-profile"
  tags = {
    Name = "${var.eks_config_cluster_name}-dev-database"
  }
}

resource "aws_volume_attachment" "database" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.database.id
  instance_id = aws_instance.database.id
}

resource "aws_ebs_volume" "database" {

  availability_zone = var.dev_database_availability_zone
  size              = var.dev_database_volume_size

  type = var.dev_database_volume_type
  iops = var.dev_database_volume_iops
  tags = {
    Project = "anhlt"
    Environment = "dev"
  }

  depends_on = [ aws_instance.database ]
}


# Create Route53 record
resource "aws_route53_record" "database" {
  zone_id = data.aws_route53_zone.private_zone.zone_id
  name    = "${var.eks_config_cluster_name}-dev-database"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.database.private_ip]
}
