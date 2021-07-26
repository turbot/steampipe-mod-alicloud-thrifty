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
    control.unused_vpc_nat_gateways,
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

control "unused_vpc_nat_gateways" {
  title         = "Unused NAT gateways should be reviewed"
  description   = "NAT Gateway is charged on an hourly basis once it is provisioned and available, check why these are available but not used."

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
      end as reason,
      -- Additional Dimensions
      nat.region,
      nat.account_id
    from
      alicloud_vpc_nat_gateway as nat
      left join instance_data as i on nat_gateway_private_info ->> 'VswitchId' = i.vswitch_id;
  EOT

  severity      = "low"
  tags = merge(local.vpc_common_tags, {
    class = "unused"
  })
}