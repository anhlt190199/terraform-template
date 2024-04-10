locals {
  domain_name = var.domain
}

module "acm" {
  source = "terraform-aws-modules/acm/aws"
  version = "v4.5.0"

  providers = {
    aws = aws.global
  }

  domain_name = local.domain_name
  zone_id     = data.cloudflare_zone.this.id

  subject_alternative_names = var.subject_alternative_names

  create_route53_records  = false
  validation_record_fqdns = cloudflare_record.validation[*].hostname

  tags = {
    Name = local.domain_name
  }
}

#module "acm_regional" {
#  source = "terraform-aws-modules/acm/aws"
#
#  domain_name = local.domain_name
#  zone_id     = data.cloudflare_zone.this.id
#
#
#
#  subject_alternative_names = var.subject_alternative_names
#
#  create_route53_records  = false
#  validation_record_fqdns = cloudflare_record.validation[*].hostname
#
#  tags = {
#    Name = local.domain_name
#  }
#}


resource "cloudflare_record" "validation" {
  count = length(module.acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.this.id
  name    = element(module.acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.acm.validation_domains, count.index)["resource_record_type"]
  value   = trimsuffix(element(module.acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = false
}

data "cloudflare_zone" "this" {
  name = local.domain_name
}