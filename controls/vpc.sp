locals {
  vpc_common_tags = merge(local.thrifty_common_tags, {
    service = "vpc"
  })
}

benchmark "vpc" {
  title         = "VPC Checks"
  description   = "Thrifty developers eliminate unused IP addresses."
  documentation = file("./controls/docs/vpc.md")
  tags          = local.vpc_common_tags
  children = [
    control.vpc_eip_unattached
  ]
}

control "vpc_eip_unattached" {
  title       = "Unattached external IP addresses should be removed"
  description = "Unattached external IPs cost money and should be released."
  severity    = "low"

  sql = <<-EOT
    select
      'acs:vpc:' || region || ':' || account_id || ':' || 'eip/' || allocation_id as resource,
      case
        when status = 'Available' then 'alarm'
        else 'ok'
      end as status,
      case
        when status = 'Available' then ip_address || ' not attached.'
        else ip_address || ' is attached.'
      end as reason,
      region,
      account_id
    from
      alicloud_vpc_eip;
  EOT

  tags = merge(local.vpc_common_tags, {
    class = "unused"
  })
}