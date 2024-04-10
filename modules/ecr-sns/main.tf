data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "ecr_scan_alert" {
  name         = var.sns_topic_name
  display_name = var.sns_topic_display_name
}

data "aws_iam_policy_document" "ecr_scan_alert" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.ecr_scan_alert.arn
    ]

    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "sns:Publish"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.ecr_scan_alert.arn
    ]

    sid = "TrustCWEToPublishEventsToMyTopic"
  }
}

resource "aws_sns_topic_policy" "ecr_scan_alert" {
  arn    = aws_sns_topic.ecr_scan_alert.arn
  policy = data.aws_iam_policy_document.ecr_scan_alert.json
}


resource "aws_sns_topic_subscription" "ecr_scan_alert" {
  topic_arn = aws_sns_topic.ecr_scan_alert.arn
  protocol  = "email"
  endpoint  = var.mail_lists
}