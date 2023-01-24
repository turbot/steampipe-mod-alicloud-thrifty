locals {
  actiontrail_common_tags = merge(local.alicloud_thrifty_common_tags, {
    service = "AliCloud/ActionTrail"
  })
}

benchmark "actiontrail" {
  title         = "ActionTrail Checks"
  description   = "Thrifty developers know that multiple active ActionTrail trails can add significant costs. Be thrifty and eliminate the extra trails. One trail to rule them all."
  documentation = file("./controls/docs/actiontrail.md")
  children = [
    control.actiontrail_multiple_global_trails,
    control.actiontrail_multiple_regional_trails
  ]

  tags = merge(local.actiontrail_common_tags, {
    type = "Benchmark"
  })
}

control "actiontrail_multiple_global_trails" {
  title       = "Redundant enabled global ActionTrail trails should be reviewed"
  description = "Your ActionTrail trails in each account are charged based on the billing policies of an Object Storage Service (OSS) bucket or a Log Service Logstore."
  severity    = "low"

  sql = <<-EOT
    with global_trails as (
      select
        count(*) as total
      from
        alicloud_action_trail
      where
        trail_region = 'All'
        and status = 'Enable'
    )
    select
      'acs:actiontrail:' || home_region || ':' || account_id || ':actiontrail/' || name as resource,
      case
        when total > 1 then 'alarm'
        else 'ok'
      end as status,
      case
        when total > 1 then name || ' is one of ' || total || ' global trails.'
        else name || ' is the only global trail.'
      end as reason
      ${local.common_dimensions_sql}
    from
      alicloud_action_trail,
      global_trails
    where
      trail_region = 'All'
      and status = 'Enable';
  EOT

  tags = merge(local.actiontrail_common_tags, {
    class = "managed"
  })
}

control "actiontrail_multiple_regional_trails" {
  title = "Redundant enabled regional ActionTrail trails should be reviewed"
  description   = "Your actiontrail in each region is charged based on the billing policies of an Object Storage Service (OSS) bucket or a Log Service Logstore."
  severity      = "low"

  sql = <<-EOT
    with
      global_trails as (
        select
          count(*) as total
        from
          alicloud_action_trail
        where
          trail_region = 'All'
          and status = 'Enable'
      ),
      org_trails as (
        select
          count(*) as total
        from
          alicloud_action_trail
        where
          trail_region = 'All'
          and status = 'Enable'
      ),
      regional_trails as (
        select
          region,
          count(*) as total
        from
          alicloud_action_trail
        where
          status = 'Enable'
          and not trail_region = 'All'
          and not is_organization_trail
        group by
          region
      )
      select
        'acs:actiontrail:' || home_region || ':' || account_id || ':actiontrail/' || name as resource,
        case
          when global_trails.total > 0 then 'alarm'
          when org_trails.total > 0 then 'alarm'
          when regional_trails.total > 1 then 'alarm'
          else 'ok'
        end as status,
        case
          when global_trails.total > 0 then name || ' is redundant to a global trail.'
          when org_trails.total > 0 then name || ' is redundant to a organizational trail.'
          when regional_trails.total > 1 then name || ' is one of ' || regional_trails.total || ' trails in ' || t.region || '.'
          else name || ' is the only regional trail.'
        end as reason
      ${replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "t.")}
      from
        alicloud_action_trail as t,
        global_trails,
        org_trails,
        regional_trails
      where
        status = 'Enable'
        and regional_trails.region = t.region
        and not trail_region = 'All'
        and not is_organization_trail;
  EOT

  tags = merge(local.actiontrail_common_tags, {
    class = "managed"
  })
}
