resource "aws_wafv2_web_acl" "staging" {
  provider = aws.global

  description = "Custom WAFWebACL"
  name        = "WAF-staging-automation"
  scope       = "CLOUDFRONT"
  tags = {
    "ManagedBy" = "cloudformation"
  }
  tags_all = {
    "ManagedBy" = "cloudformation"
  }

  default_action {
    allow {
    }
  }

  rule {
    name     = "WAF-staging-automationWhitelistRule"
    priority = 0

    action {
      allow {
      }
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/WAF-staging-automationWhitelistSetIPV4/63359a0a-56ac-4d01-a24f-5d56ac2a7920"
          }
        }
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/WAF-staging-automationWhitelistSetIPV6/9dbdd31f-bdac-4f5d-95cf-7b40a9541259"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WAFstagingautomationWhitelistRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "WAF-staging-automationBadBotRule"
    priority = 3

    action {
      block {
      }
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/WAF-staging-automationIPBadBotSetIPV4/c4810af1-49eb-46c4-8cff-a4eee5a916ac"
          }
        }
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/WAF-staging-automationIPBadBotSetIPV6/7d77fa5b-ceb5-4dde-bfe6-de7c6243fee5"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WAFstagingautomationBadBotRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "WAF-staging-automationBlacklistRule"
    priority = 1

    action {
      block {
      }
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/WAF-staging-automationBlacklistSetIPV4/3eb37082-2f0b-4617-8bb0-3ff027fa2e77"
          }
        }
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/WAF-staging-automationBlacklistSetIPV6/a4b4b3ba-ce29-4c06-b982-c7257dbb799e"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WAFstagingautomationBlacklistRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "WAF-staging-automationHttpFloodRateBasedRule"
    priority = 7

    action {
      count {
      }
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 1000
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WAFstagingautomationHttpFloodRateBasedRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "WAF-staging-automationIPReputationListsRule"
    priority = 2

    action {
      block {
      }
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/WAF-staging-automationIPReputationListsSetIPV4/015c5215-e87b-4381-9cc4-e4cc1f161ef8"
          }
        }
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/WAF-staging-automationIPReputationListsSetIPV6/33f69700-d8eb-449e-b680-31fa2e65fd20"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WAFstagingautomationIPReputationListsRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "WAF-staging-automationScannersAndProbesRule"
    priority = 6

    action {
      block {
      }
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/WAF-staging-automationScannersProbesSetIPV4/aa9d63bd-1634-490d-b690-d816737f44e6"
          }
        }
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/WAF-staging-automationScannersProbesSetIPV6/5343e137-b353-4282-be9a-ccd2785b684c"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WAFstagingautomationScannersProbesRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "WAF-staging-automationSqlInjectionRule"
    priority = 5

    action {
      count {
      }
    }

    statement {
      or_statement {
        statement {
          sqli_match_statement {
            field_to_match {
              query_string {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          sqli_match_statement {
            field_to_match {
              body {
                oversize_handling = "CONTINUE"
              }
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          sqli_match_statement {
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          sqli_match_statement {
            field_to_match {
              single_header {
                name = "authorization"
              }
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          sqli_match_statement {
            field_to_match {
              single_header {
                name = "cookie"
              }
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WAFstagingautomationSqlInjectionRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "NoUserAgent_HEADER"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "SizeRestrictions_Cookie_HEADER"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "SizeRestrictions_BODY"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "SizeRestrictions_QUERYSTRING"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "GenericRFI_QUERYARGUMENTS"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "GenericRFI_BODY"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "GenericRFI_URIPATH"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "CrossSiteScripting_BODY"

          action_to_use {
            count {
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "MetricForAMRCRS"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFstagingautomationWAFWebACL"
    sampled_requests_enabled   = true
  }
}


resource "aws_wafv2_web_acl" "production" {
  name        = "waf-production-automation"
  scope       = "CLOUDFRONT"
  description = "Custom WAFWebACL"

  provider = aws.global


  tags = {}
  default_action {
    allow {
    }
  }

  rule {
    name     = "waf-production-automationWhitelistRule"
    priority = 0

    action {
      allow {
      }
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/waf-production-automationWhitelistSetIPV4/bcf9fca4-6331-4204-8033-fc369a96bec2"
          }
        }
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/waf-production-automationWhitelistSetIPV6/4ea3d5a4-5974-4be1-b5e6-ad6983f240e3"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafproductionautomationWhitelistRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "waf-production-automationBadBotRule"
    priority = 3

    action {
      block {
      }
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/waf-production-automationIPBadBotSetIPV4/695882a4-ecd5-4af2-8abd-9d608d357b86"
          }
        }
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/waf-production-automationIPBadBotSetIPV6/d4365cb5-60ed-4d9c-9015-2c2f9b69c9ec"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafproductionautomationBadBotRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "waf-production-automationBlacklistRule"
    priority = 1

    action {
      block {
      }
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/waf-production-automationBlacklistSetIPV4/7d9efba3-1e4b-46dd-b8af-71aea5d7b9b7"
          }
        }
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/waf-production-automationBlacklistSetIPV6/49d4a59f-b7a8-474e-9dde-97cc2e6b5161"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafproductionautomationBlacklistRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "waf-production-automationHttpFloodRateBasedRule"
    priority = 6

    action {
      block {
      }
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 1000
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafproductionautomationHttpFloodRateBasedRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "waf-production-automationIPReputationListsRule"
    priority = 2

    action {
      block {
      }
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/waf-production-automationIPReputationListsSetIPV4/4858f9a6-adfe-4cea-afd7-5a65ff9f9706"
          }
        }
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/waf-production-automationIPReputationListsSetIPV6/29f3d60e-7326-4e34-b931-a01729e7b5b6"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafproductionautomationIPReputationListsRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "waf-production-automationScannersAndProbesRule"
    priority = 5

    action {
      block {
      }
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/waf-production-automationScannersProbesSetIPV4/df525de2-f020-470c-8e53-736d78a816af"
          }
        }
        statement {
          ip_set_reference_statement {
            arn = "arn:aws:wafv2:us-east-1:814793154525:global/ipset/waf-production-automationScannersProbesSetIPV6/d68a2a96-7851-482c-8f79-880c4683be33"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafproductionautomationScannersProbesRule"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "NoUserAgent_HEADER"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "SizeRestrictions_QUERYSTRING"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "SizeRestrictions_Cookie_HEADER"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "SizeRestrictions_BODY"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "GenericRFI_QUERYARGUMENTS"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "GenericRFI_BODY"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "GenericRFI_URIPATH"

          action_to_use {
            count {
            }
          }
        }
        rule_action_override {
          name = "CrossSiteScripting_BODY"

          action_to_use {
            count {
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "MetricForAMRCRS"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "wafproductionautomationWAFWebACL"
    sampled_requests_enabled   = true
  }

}