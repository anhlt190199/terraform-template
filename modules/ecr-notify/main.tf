data "aws_caller_identity" "current" {}

data "template_file" "ecr_alert" {
  template = file("${path.module}/event_pattern.json")
}

resource "aws_cloudwatch_event_rule" "ecr_alert" {
  name          = var.event_rule_name
  description   = "A CloudWatch Event Rule that triggers when each ECR vulnerability image scan is completed"
  event_pattern = data.template_file.ecr_alert.rendered

}

resource "aws_cloudwatch_event_target" "ecr_alert" {
  rule      = aws_cloudwatch_event_rule.ecr_alert.name
  target_id = var.target_id
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      resource = "$.resources",
      findings = "$.detail.finding-severity-counts",
      repo     = "$.detail.repository-name",
      digest   = "$.detail.image-digest",
      time     = "$.time",
      region   = "$.region",
      account  = "$.account",
      status   = "$.detail.scanstatus",
      tags     = "$.detail.image-tags"
    }
    input_template = <<EOF
"ECR Image scan results:"
"Time: <time>"
"Acc : <account>"
"Repo: <repo>"
"SHA : <digest>"
"Tags: <tags>"
"Find: <findings>"
EOF
  }
}

