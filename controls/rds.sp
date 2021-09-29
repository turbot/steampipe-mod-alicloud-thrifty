variable "rds_db_instance_age_max_days" {
  type        = number
  description = "The maximum number of days DB instances can be running."
}

variable "rds_db_instance_age_warning_days" {
  type        = number
  description = "The number of days DB instances can be running before sending a warning."
}

variable "rds_db_instance_avg_connections" {
  type        = number
  description = "The minimum number of average connections per day required for DB instances to be considered in-use."
}

locals {
  rds_common_tags = merge(local.thrifty_common_tags, {
    service = "rds"
  })
}

benchmark "rds" {
  title         = "RDS Checks"
  description   = "Thrifty developers check long running rds databases should have billing type as 'Subscription' instead of 'Pay-as-you-go'."
  documentation = file("./controls/docs/rds.md")
  tags          = local.rds_common_tags
  children = [
    control.rds_db_instance_long_running,
    control.rds_db_instance_low_connection_count
  ]
}

control "rds_db_instance_long_running" {
  title       = "Long running RDS DB instances should have billing type as 'Subscription' instead of 'Pay-as-you-go'."
  description = "Subscription billing for long running RDS DB instances is more cost effective and you can receive larger discounts for longer subscription periods."
  severity    = "low"

  sql = <<-EOT
    select
      arn as resource,
      case
        when date_part('day', now() - creation_time) > $1 then 'alarm'
        when date_part('day', now() - creation_time) > $2 then 'info'
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

  param "rds_db_instance_age_max_days" {
    description = "The maximum number of days DB instances can be running."
    default     = var.rds_db_instance_age_max_days
  }

  param "rds_db_instance_age_warning_days" {
    description = "The number of days DB instances can be running before sending a warning."
    default     = var.rds_db_instance_age_warning_days
  }

  tags = merge(local.rds_common_tags, {
    class = "managed"
  })
}

control "rds_db_instance_low_connection_count" {
  title       = "RDS DB instances with a low number connections per day should be reviewed"
  description = "These databases have had very little usage in the last 30 days and should be shut down when not in use."
  severity    = "high"

  sql = <<-EOT
    with rds_db_usage as (
      select
        db_instance_id,
        round(sum(maximum)/count(maximum)) as avg_max,
        count(maximum) as days
      from
        alicloud_rds_instance_metric_connections_daily
      where
        date_part('day', now() - timestamp) <=30
      group by
        db_instance_id
    )
    select
      arn as resource,
      case
        when avg_max is null then 'error'
        when avg_max = 0 then 'alarm'
        when avg_max < $1 then 'info'
        else 'ok'
      end as status,
      case
        when avg_max is null then 'Cloud monitor metrics not available for ' || title || '.'
        when avg_max = 0 then title || ' has not been connected to in the last ' || days || ' days.'
        else title || ' is averaging ' || avg_max || ' max connections/day in the last ' || days || ' days.'
      end as reason,
      region,
      account_id
    from
      alicloud_rds_instance as i
      left join rds_db_usage as u on u.db_instance_id = i.db_instance_id;
  EOT

  param "rds_db_instance_avg_connections" {
    description = "The minimum number of average connections per day required for DB instances to be considered in-use."
    default     = var.rds_db_instance_avg_connections
  }

  tags = merge(local.rds_common_tags, {
    class = "unused"
  })
}
