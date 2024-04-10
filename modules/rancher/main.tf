resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.eks_config_cluster_name}-rancher-kp"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${aws_key_pair.deployer.key_name}.pem"
  content         = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

resource "aws_security_group" "sg_dev_rancher" {
  name        = "sg_dev_rancher"
  description = "allow connect to internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "http"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "https"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.eks_config_cluster_name}-rancher-sg"
  }
}

resource "aws_instance" "rancher" {
  associate_public_ip_address = true
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = aws_key_pair.deployer.key_name
  ami                         = data.aws_ami.ami.id
  vpc_security_group_ids      = [aws_security_group.sg_dev_rancher.id]
  iam_instance_profile        = "${var.eks_config_cluster_name}-ssm-instance-profile"
  tags = {
    Name = "${var.eks_config_cluster_name}-rancher"
  }
}

# Create Route53 record
resource "aws_route53_record" "rancher" {
  zone_id = data.aws_route53_zone.private_zone.zone_id
  name    = "rancher"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.rancher.private_ip]
}
