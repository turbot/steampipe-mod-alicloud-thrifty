locals {
  vpc_common_tags = merge(local.alicloud_thrifty_common_tags, {
    service = "AliCloud/VPC"
  })
}

benchmark "vpc" {
  title         = "VPC Checks"
  description   = "Thrifty developers eliminate unused IP addresses."
  documentation = file("./controls/docs/vpc.md")
  children = [
    control.vpc_nat_gateway_unused,
    control.vpc_eip_unattached
  ]

  tags = merge(local.vpc_common_tags, {
    type = "Benchmark"
  })
}

control "vpc_eip_unattached" {
  title       = "Unattached external IP addresses should be released"
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
      end as reason
      ${local.common_dimensions_sql}
    from
      alicloud_vpc_eip;
  EOT

  tags = merge(local.vpc_common_tags, {
    class = "unused"
  })
}

control "vpc_nat_gateway_unused" {
  title       = "Unused NAT gateways should be deleted"
  description = "NAT gateways are charged on an hourly basis once provisioned and available. Unused NAT gateways should be deleted if not used."
  severity    = "low"

  sql = <<-EOT
    with instance_data as (
      select
        instance_id,
        vpc_attributes ->> 'VSwitchId' as vswitch_id,
        status
      from
        alicloud_ecs_instance
    )
    select
      -- Required Columns
      'acs:vpc:' || nat.region || ':' || nat.account_id || ':natgateway/' || nat_gateway_id as resource,
      case
        when nat.status <> 'Available' then 'alarm'
        when i.vswitch_id is null then 'alarm'
        when i.status <> 'Running' then 'alarm'
        else 'ok'
      end as status,
      case
        when nat.status <> 'Available' then nat.title || ' in ' || nat.status || ' state.'
        when i.vswitch_id is null then nat.title || ' not in-use.'
        when i.status <> 'Running' then nat.title || ' associated with ' || i.instance_id || ', which is in ' || lower(i.status) || ' state.'
        else nat.title || ' in-use.'
      end as reason
      -- Additional Dimensions
      ${replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "nat.")}
    from
      alicloud_vpc_nat_gateway as nat
      left join instance_data as i on nat_gateway_private_info ->> 'VswitchId' = i.vswitch_id;
  EOT

  tags = merge(local.vpc_common_tags, {
    class = "unused"
  })
}
