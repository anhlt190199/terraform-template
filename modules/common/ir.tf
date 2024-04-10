# policy AmazonEC2RoleforSSM
data "aws_iam_policy" "AmazonEC2RoleforSSM" {
  name = "AmazonEC2RoleforSSM"
}
# create instance role with SSM policy
resource "aws_iam_role" "ssm-instance-role" {
  name = "${var.common_name_prefix}-ssm-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm-instance-role" {
  role       = aws_iam_role.ssm-instance-role.name
  policy_arn = data.aws_iam_policy.AmazonEC2RoleforSSM.arn
}

resource "aws_iam_instance_profile" "ssm-instance-profile" {
  name = "${var.common_name_prefix}-ssm-instance-profile"
  role = aws_iam_role.ssm-instance-role.name
}