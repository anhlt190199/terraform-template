variable "sns_topic_name" {
  type        = string
  description = "The friendly name for the SNS topic. By default generated by Terraform."
}
variable "sns_topic_display_name" {
  type        = string
  description = "The display name for the SNS topic"
}
variable "mail_lists" {
  type        = string
  description = "List mails to subscription"
}