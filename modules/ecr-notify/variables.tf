variable "event_rule_name" {
  type        = string
  description = "Name of event rule"
}
variable "target_id" {
  type        = string
  description = "The unique target assignment ID. If missing, will generate a random, unique id."
}
variable "sns_topic_arn" {
  type        = string
  description = "The ARN of sns topic"
}
