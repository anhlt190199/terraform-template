[![GitHub release (latest by date)](https://img.shields.io/github/v/release/umotif-public/terraform-aws-waf-webaclv2)](https://github.com/umotif-public/terraform-aws-waf-webaclv2/releases/latest)

# terraform-aws-waf-webaclv2

Terraform module to configure WAF Web ACL V2 for Application Load Balancer or Cloudfront distribution.

Supported WAF v2 components:

- Module supports all AWS managed rules defined in https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html.
- Associating WAFv2 ACL with one or more Application Load Balancers (ALB)
- Blocking IP Sets
- Rate limiting IPs (and optional scopedown statements)
- Byte Match statements
- Geo set statements
- Logical Statements (AND, OR, NOT)
- Size constraint statements
- Label Match statements
- Custom responses

## Usage

Please pin down version of this module to exact version

If referring directly to the code instead of a pinned version, take note that from release 3.0.0 all future changes will only be made to the `main` branch.

```hcl
module "waf" {

  name = "test-waf-setup"

  scope = "REGIONAL"

  allow_default_action = true # set to allow if not specified

  visibility_config = {
    metric_name = "test-waf-setup-waf-main-metrics"
  }

  rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet-rule-1"
      priority = "1"

      override_action = "none"

      visibility_config = {
        metric_name                = "AWSManagedRulesCommonRuleSet-metric"
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        excluded_rule = [
          "SizeRestrictions_QUERYSTRING",
          "SizeRestrictions_BODY",
          "GenericRFI_QUERYARGUMENTS"
        ]
      }
    },
    {
      name     = "AWSManagedRulesKnownBadInputsRuleSet-rule-2"
      priority = "2"

      override_action = "count"

      visibility_config = {
        metric_name = "AWSManagedRulesKnownBadInputsRuleSet-metric"
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    },
    {
      name     = "AWSManagedRulesPHPRuleSet-rule-3"
      priority = "3"

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "AWSManagedRulesPHPRuleSet-metric"
        sampled_requests_enabled   = false
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    },
  
    ### IP Set Rule example
    {
      name     = "IpSetRule-6"
      priority = "6"

      action = "allow"

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "IpSetRule-metric"
        sampled_requests_enabled   = false
      }

      ip_set_reference_statement = {
        ip_set_index = 0
      }
    },
    ### IP Rate Based Rule example
    {
      name     = "IpRateBasedRule-7"
      priority = "7"

      action = "block"

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "IpRateBasedRule-metric"
        sampled_requests_enabled   = false
      }

      rate_based_statement = {
        limit              = 100
        aggregate_key_type = "IP"
        # Optional scope_down_statement to refine what gets rate limited
        scope_down_statement = {
          not_statement = {
            byte_match_statement = {
              field_to_match = {
                uri_path = "{}"
              }
              positional_constraint = "STARTS_WITH"
              search_string         = "/path/to/match"
              priority              = 0
              type                  = "NONE"
            }
          }
        }
      }
    }
  ]

  wafv2_ip_set = [
    {
      name               = "example"
      description        = "Example IP set"
      scope              = "REGIONAL"
      ip_address_version = "IPV4"
      addresses          = ["1.2.3.4/32", "5.6.7.8/32"]
      tags = {
        Tag1 = "Value1"
      }
    }
  ]

  tags = {
    "Name" = "test-waf-setup"
    "Env"  = "test"
  }
}
```
## Logging configuration

When you enable logging configuration for WAFv2. Remember to follow naming convention defined in https://docs.aws.amazon.com/waf/latest/developerguide/logging.html.

Importantly, make sure that Amazon Kinesis Data Firehose is using a name starting with the prefix aws-waf-logs-.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_ip_set.ip_set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_web_acl.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.alb_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_arn"></a> [alb\_arn](#input\_alb\_arn) | Application Load Balancer ARN list | `list(string)` | `[]` | no |
| <a name="input_allow_default_action"></a> [allow\_default\_action](#input\_allow\_default\_action) | Set to `true` for WAF to allow requests by default. Set to `false` for WAF to block requests by default. | `bool` | `true` | no |
| <a name="input_create_web_acl_association"></a> [create\_alb\_association](#input\_create\_alb\_association) | Whether to create alb association with WAF web acl | `bool` | `false` | no |
| <a name="input_create_logging_configuration"></a> [create\_logging\_configuration](#input\_create\_logging\_configuration) | Whether to create logging configuration in order start logging from a WAFv2 Web ACL to Amazon Kinesis Data Firehose. | `bool` | `false` | no |
| <a name="input_create_waf"></a> [create\_waf](#input\_create\_waf) | Whether to create the resources. Set to `false` to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_custom_response_bodies"></a> [custom\_response\_bodies](#input\_custom\_response\_bodies) | Custom response bodies to be referenced on a per rule basis. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#custom-response-body | <pre>list(object({<br>    key          = string<br>    content      = string<br>    content_type = string<br>  }))</pre> | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | A friendly description of the WebACL | `string` | `null` | no |
| <a name="input_log_destination_configs"></a> [log\_destination\_configs](#input\_log\_destination\_configs) | The Amazon Kinesis Data Firehose Amazon Resource Name (ARNs) that you want to associate with the web ACL. Currently, only 1 ARN is supported. | `list(string)` | `[]` | no |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation. | `any` | `{}` | no |
| <a name="input_redacted_fields"></a> [redacted\_fields](#input\_redacted\_fields) | The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported. | `any` | `[]` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | List of WAF rules. | `any` | `[]` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL. To work with CloudFront, you must also specify the region us-east-1 (N. Virginia) on the AWS provider. | `string` | `"REGIONAL"` | no |
| <a name="input_visibility_config"></a> [visibility\_config](#input\_visibility\_config) | Visibility config for WAFv2 web acl. https://www.terraform.io/docs/providers/aws/r/wafv2_web_acl.html#visibility-configuration | `map(string)` | `{}` | no |
| <a name="input_waf_name"></a> [waf\_name](#input\_waf\_name) | Friendly name of the WebACL | `string` | n/a | yes |
| <a name="input_wafv2_ip_set"></a> [wafv2\_ip\_set](#input\_wafv2\_ip\_set) | A list of maps describing WAFv2 IP Set. Required key/values: name, scope, ip\_address\_version, addresses. | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_web_acl_arn"></a> [web\_acl\_arn](#output\_web\_acl\_arn) | The ARN of the WAFv2 WebACL. |
| <a name="output_web_acl_assoc_acl_arn"></a> [web\_acl\_assoc\_acl\_arn](#output\_web\_acl\_assoc\_acl\_arn) | The ARN of the Web ACL attached to the Web ACL Association |
| <a name="output_web_acl_assoc_alb_list_acl_arn"></a> [web\_acl\_assoc\_alb\_list\_acl\_arn](#output\_web\_acl\_assoc\_alb\_list\_acl\_arn) | The ARN of the Web ACL attached to the Web ACL Association for the alb\_list resource |
| <a name="output_web_acl_assoc_alb_list_id"></a> [web\_acl\_assoc\_alb\_list\_id](#output\_web\_acl\_assoc\_alb\_list\_id) | The ID of the Web ACL Association for the alb\_list resource |
| <a name="output_web_acl_assoc_alb_list_resource_arn"></a> [web\_acl\_assoc\_alb\_list\_resource\_arn](#output\_web\_acl\_assoc\_alb\_list\_resource\_arn) | The ARN of the ALB attached to the Web ACL Association for the alb\_list resource |
| <a name="output_web_acl_assoc_id"></a> [web\_acl\_assoc\_id](#output\_web\_acl\_assoc\_id) | The ID of the Web ACL Association |
| <a name="output_web_acl_assoc_resource_arn"></a> [web\_acl\_assoc\_resource\_arn](#output\_web\_acl\_assoc\_resource\_arn) | The ARN of the ALB attached to the Web ACL Association |
| <a name="output_web_acl_capacity"></a> [web\_acl\_capacity](#output\_web\_acl\_capacity) | The web ACL capacity units (WCUs) currently being used by this web ACL. |
| <a name="output_web_acl_id"></a> [web\_acl\_id](#output\_web\_acl\_id) | The ID of the WAFv2 WebACL. |
| <a name="output_web_acl_name"></a> [web\_acl\_name](#output\_web\_acl\_name) | The name of the WAFv2 WebACL. |
| <a name="output_web_acl_rule_names"></a> [web\_acl\_rule\_names](#output\_web\_acl\_rule\_names) | List of created rule names |
| <a name="output_web_acl_visibility_config_name"></a> [web\_acl\_visibility\_config\_name](#output\_web\_acl\_visibility\_config\_name) | The web ACL visibility config name |
<!-- END_TF_DOCS -->