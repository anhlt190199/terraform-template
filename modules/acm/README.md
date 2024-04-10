# Complete ACM example with external CloudFlare DNS validation

##  1. <a name='TableofContents'></a>Table of Contents
<!-- vscode-markdown-toc -->
* 1. [Table of Contents](#TableofContents)
* 2. [Requirements](#Requirements)
* 3. [Providers](#Providers)
* 4. [Modules](#Modules)
* 5. [Resources](#Resources)
* 6. [Inputs](#Inputs)
* 7. [Outputs](#Outputs)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

Configuration in this directory creates an ACM certificate (valid for the domain name and wildcard) while the DNS validation is done via an external DNS provider.

For this example CloudFlare DNS is used but any DNS provider could be used instead.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
##  2. <a name='Requirements'></a>Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.40 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 3.4 |

##  3. <a name='Providers'></a>Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | >= 3.4 |

##  4. <a name='Modules'></a>Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | n/a |
| <a name="module_acm_regional"></a> [acm\_regional](#module\_acm\_regional) | terraform-aws-modules/acm/aws | n/a |

##  5. <a name='Resources'></a>Resources

| Name | Type |
|------|------|
| [cloudflare_record.validation](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_zone.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |

##  6. <a name='Inputs'></a>Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | The domain name of the site | `string` | n/a | yes |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | A list of domains that should be SANs in the issued certificate | `list(string)` | `[]` | no |

##  7. <a name='Outputs'></a>Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | The ARN of the certificate |
| <a name="output_acm_certificate_domain_validation_options"></a> [acm\_certificate\_domain\_validation\_options](#output\_acm\_certificate\_domain\_validation\_options) | A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g. if SANs are defined. Only set if DNS-validation was used. |
| <a name="output_acm_certificate_status"></a> [acm\_certificate\_status](#output\_acm\_certificate\_status) | Status of the certificate. |
| <a name="output_acm_certificate_validation_emails"></a> [acm\_certificate\_validation\_emails](#output\_acm\_certificate\_validation\_emails) | A list of addresses that received a validation E-Mail. Only set if EMAIL-validation was used. |
| <a name="output_distinct_domain_names"></a> [distinct\_domain\_names](#output\_distinct\_domain\_names) | List of distinct domains names used for the validation. |
| <a name="output_validation_domains"></a> [validation\_domains](#output\_validation\_domains) | List of distinct domain validation options. This is useful if subject alternative names contain wildcards. |
| <a name="output_validation_route53_record_fqdns"></a> [validation\_route53\_record\_fqdns](#output\_validation\_route53\_record\_fqdns) | List of FQDNs built using the zone domain and name. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->