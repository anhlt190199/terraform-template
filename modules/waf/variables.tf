################################################################################
# WAFV2 Variables
################################################################################
variable "create_waf" {
  type        = bool
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  default     = true
}

variable "waf_name" {
  type        = string
  description = "Friendly name of the WebACL"
}

variable "rules" {
  description = "List of WAF rules."
  type        = any
  default     = []
}

variable "wafv2_ip_set" {
  description = "A list of maps describing WAFv2 IP Set. Required key/values: name, scope, ip_address_version, addresses."
  type        = any
  default     = []
}

variable "visibility_config" {
  description = "Visibility config for WAFv2 web acl. https://www.terraform.io/docs/providers/aws/r/wafv2_web_acl.html#visibility-configuration"
  type        = map(string)
  default     = {}
}

variable "allow_default_action" {
  type        = bool
  description = "Set to `true` for WAF to allow requests by default. Set to `false` for WAF to block requests by default."
  default     = true
}

variable "scope" {
  type        = string
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL. To work with CloudFront, you must also specify the region us-east-1 (N. Virginia) on the AWS provider."
  default     = "REGIONAL"
}

variable "description" {
  type        = string
  description = "A friendly description of the WebACL"
  default     = null
}

variable "custom_response_bodies" {
  type = list(object({
    key          = string
    content      = string
    content_type = string
  }))
  description = "Custom response bodies to be referenced on a per rule basis. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#custom-response-body"
  default     = []
}

################################################################################
# Logging Configuration Variables
################################################################################
variable "create_logging_configuration" {
  type        = bool
  description = "Whether to create logging configuration in order start logging from a WAFv2 Web ACL to Amazon Kinesis Data Firehose."
  default     = false
}

variable "log_destination_configs" {
  type        = list(string)
  description = "The Amazon Kinesis Data Firehose Amazon Resource Name (ARNs) that you want to associate with the web ACL. Currently, only 1 ARN is supported."
  default     = []
}

variable "logging_filter" {
  type        = any
  description = "A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation."
  default     = {}
}

variable "redacted_fields" {
  description = "The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported."
  type        = any
  default     = []
}

################################################################################
# ALB Variables
################################################################################
variable "create_web_acl_association" {
  type        = bool
  description = "Whether to create alb association with WAF web acl"
  default     = false
}

variable "resource_arn" {
  type        = list(string)
  description = "List of ARNs of the resources to associate with the web ACL."
  default     = []
}

################################################################################
# Common Variables
################################################################################
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "master_prefix" {
  description = "To specify a key prefix for aws resource"
  type        = string
  default     = "dso"
}
