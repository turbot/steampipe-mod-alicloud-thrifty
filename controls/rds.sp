locals {
  rds_common_tags = merge(local.thrifty_common_tags, {
    service = "rds"
  })
}

benchmark "rds" {
  title         = "RDS Checks"
  description   = "Thrifty developers checks long running rds databases should have billing type as 'Subscription' instead of 'Pay-as-you-go'."
  documentation = file("./controls/docs/rds.md")
  tags          = local.rds_common_tags
  children = [
    control.rds_db_instances_long_running
  ]
}

control "rds_db_instances_long_running" {
  title       = "Long running RDS DB instances should have billing type as 'Subscription' instead of 'Pay-as-you-go'."
  description = "Subscription billing for long running RDS DB instances is more cost effective and you can receive larger discounts for longer subscription periods."
  severity    = "low"

  sql = <<-EOT
    select
      arn as resource,
      case
        when date_part('day', now() - creation_time) > 90 then 'alarm'
        when date_part('day', now() - creation_time) > 30 then 'info'
        else 'ok'
      end as status,
      title || ' has been in use for ' || date_part('day', now() - creation_time) || ' days.' as reason,
      region,
      account_id
    from
      alicloud_rds_instance
    where
      pay_type = 'Postpaid';
  EOT

  tags = merge(local.rds_common_tags, {
    class = "managed"
  })
}