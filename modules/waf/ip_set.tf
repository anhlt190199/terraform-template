resource "aws_wafv2_ip_set" "ip_set" {
  count              = var.create_waf && length(var.wafv2_ip_set) > 0 ? length(var.wafv2_ip_set) : 0
  name               = format("%s-%s", var.master_prefix, lookup(var.wafv2_ip_set[count.index], "name"))
  description        = lookup(var.wafv2_ip_set[count.index], "description", null)
  scope              = lookup(var.wafv2_ip_set[count.index], "scope")
  ip_address_version = lookup(var.wafv2_ip_set[count.index], "ip_address_version")

  # generates a list of all /16s
  addresses = lookup(var.wafv2_ip_set[count.index], "addresses")
  tags = merge(
    lookup(var.wafv2_ip_set[count.index], "tag", {}),
    var.tags
  )
}
