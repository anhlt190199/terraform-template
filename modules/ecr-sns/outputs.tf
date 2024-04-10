output "sns_topic_arn" {
  value       = aws_sns_topic.ecr_scan_alert.arn
  description = " The ARN of the SNS topic"
}