# =================================================================================================
# CREATE PREFIX-LIST FOR CLOUDFRONT, ALB will use this to allow traffic from cloudfront to ALB
# =================================================================================================
# create security prefix-list for cloudfront
data "aws_ec2_managed_prefix_list" "cloudfront" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.global.cloudfront.origin-facing"]
  }
  depends_on = [module.vpc]
}

# create security group for cloudfront
resource "aws_security_group" "cloudfront" {
  name        = "${var.eks_config_cluster_name}-cloudfront"
  description = "Allow traffic from cloudfront"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }
  #  all outbound traffic allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.eks_config_cluster_name}-cloudfront"
  }

  depends_on = [data.aws_ec2_managed_prefix_list.cloudfront]
}
