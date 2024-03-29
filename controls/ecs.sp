variable "ecs_disk_max_iops" {
  type        = number
  description = "The maximum IOPS allowed for disks."
  default     = 32000
}

variable "ecs_disk_max_size_gb" {
  type        = number
  description = "The maximum size in GB allowed for disks."
  default     = 100
}

variable "ecs_instance_allowed_types" {
  type        = list(string)
  description = "A list of allowed instance types. PostgreSQL wildcards are supported."
  default     = ["%.nano", "%.small", "%._large", ".__large"]
}

variable "ecs_instance_avg_cpu_utilization_low" {
  type        = number
  description = "The average CPU utilization required for instances to be considered infrequently used. This value should be lower than ecs_instance_avg_cpu_utilization_high."
  default     = 20
}

variable "ecs_instance_avg_cpu_utilization_high" {
  type        = number
  description = "The average CPU utilization required for instances to be considered frequently used. This value should be higher than ecs_instance_avg_cpu_utilization_low."
  default     = 35
}

variable "ecs_running_instance_age_max_days" {
  type        = number
  description = "The maximum number of days an instance are allowed to run."
  default     = 90
}

variable "ecs_snapshot_age_max_days" {
  type        = number
  description = "The maximum number of days a snapshot can be retained."
  default     = 90
}

locals {
  ecs_common_tags = merge(local.alicloud_thrifty_common_tags, {
    service = "AliCloud/ECS"
  })
}

benchmark "ecs" {
  title         = "ECS Checks"
  description   = "Thrifty developers eliminate unused and under-utilized ECS resources."
  documentation = file("./controls/docs/ecs.md")
  children = [
    control.ecs_disk_attached_stopped_instance,
    control.ecs_disk_high_iops,
    control.ecs_disk_large,
    control.ecs_disk_unattached,
    control.ecs_instance_large,
    control.ecs_instance_with_low_utilization,
    control.ecs_instance_long_running,
    control.ecs_snapshot_max_age
  ]

  tags = merge(local.ecs_common_tags, {
    type = "Benchmark"
  })
}

control "ecs_disk_attached_stopped_instance" {
  title       = "Disks attached to stopped instances should be reviewed"
  description = "Instances that are stopped may no longer need any attached disks."
  severity    = "low"

  sql = <<-EOQ
    select
      d.arn as resource,
      case
        when d.instance_id is null then 'skip'
        when i.status = 'Running' then 'ok'
        else 'alarm'
      end as status,
      case
        when d.instance_id is null then d.title || ' not attached to instance.'
        when i.status = 'Running' then d.title || ' attached to running instance' || ' ' || d.instance_id || '.'
        else d.title || ' attached to stopped instance' || ' ' || d.instance_id || '.'
      end as reason
      ${replace(local.tag_dimensions_qualifier_sql, "__QUALIFIER__", "d.")}
      ${replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "d.")}
    from
      alicloud_ecs_disk as d
      left join alicloud_ecs_instance as i on d.instance_id = i.instance_id;
  EOQ

  tags = merge(local.ecs_common_tags, {
    class = "deprecated"
  })
}

control "ecs_disk_large" {
  title       = "Disks should be resized if too large"
  description = "Large disks are unusual, expensive and should be reviewed."
  severity    = "low"

  sql = <<-EOQ
    select
      arn as resource,
      case
        when size <= $1 then 'ok'
        else 'alarm'
      end as status,
      disk_id || ' is ' || size || ' GiB.' as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      alicloud_ecs_disk;
  EOQ

  param "ecs_disk_max_size_gb" {
    description = "The maximum size in GB allowed for disks."
    default     = var.ecs_disk_max_size_gb
  }

  tags = merge(local.ecs_common_tags, {
    class = "deprecated"
  })
}

control "ecs_disk_unattached" {
  title       = "Unattached disks should be removed"
  description = "Unattached disks are charged by Alicloud, they should be removed unless there is a business need to retain them."
  severity    = "low"

  sql = <<-EOQ
    select
      arn as resource,
      case
        when status = 'Available' then 'alarm'
        else 'ok'
      end as status,
      case
        when status = 'Available' then title || ' has no attachment.'
        else title || ' has attachment.'
      end as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      alicloud_ecs_disk;
  EOQ

  tags = merge(local.ecs_common_tags, {
    class = "unused"
  })
}

control "ecs_instance_large" {
  title       = "Large ECS instances should be reviewed"
  description = "Large ECS instances are unusual, expensive and should be reviewed."
  severity    = "low"

  sql = <<-EOQ
    select
      arn as resource,
      case
        when status not in ('Running', 'Pending', 'Starting') then 'info'
        when instance_type like any ($1) then 'ok'
        else 'alarm'
      end as status,
      title || ' has type ' || instance_type || ' and is ' || status || '.' as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      alicloud_ecs_instance;
  EOQ

  param "ecs_instance_allowed_types" {
    description = "A list of allowed instance types. PostgreSQL wildcards are supported."
    default     = var.ecs_instance_allowed_types
  }

  tags = merge(local.ecs_common_tags, {
    class = "deprecated"
  })
}

control "ecs_instance_long_running" {
  title       = "Long running instances should be reviewed"
  description = "Instances should ideally be ephemeral and rehydrated frequently. Check why these instances have been running for so long."
  severity    = "low"

  sql = <<-EOQ
    select
      arn as resource,
      case
        when date_part('day', now() - creation_time) > $1 then 'alarm'
        else 'ok'
      end as status,
      title || ' has been running ' || date_part('day', now() - creation_time) || ' days.' as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      alicloud_ecs_instance
    where
      status = 'Running';
  EOQ

  param "ecs_running_instance_age_max_days" {
    description = "The maximum number of days an instance are allowed to run."
    default     = var.ecs_running_instance_age_max_days
  }

  tags = merge(local.ecs_common_tags, {
    class = "deprecated"
  })
}

control "ecs_snapshot_max_age" {
  title       = "Old snapshots should be deleted if not required"
  description = "Old snapshots are likely unneeded and costly to maintain."
  severity    = "low"

  sql = <<-EOQ
    select
      'acs:acs:' || region || ':' || account_id || ':' || 'snapshot/' || snapshot_id as resource,
      case
        when date_part('day', now() - creation_time) < $1 then 'ok'
        else 'alarm'
      end as status,
      snapshot_id || ' created at ' || creation_time || ' (' || date_part('day', now() - creation_time) || ' days).'
      as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      alicloud_ecs_snapshot;
  EOQ

  param "ecs_snapshot_age_max_days" {
    description = "The maximum number of days a snapshot can be retained."
    default     = var.ecs_snapshot_age_max_days
  }

  tags = merge(local.ecs_common_tags, {
    class = "unused"
  })
}

control "ecs_disk_high_iops" {
  title       = "ECS disks with high IOPS should be reviewed"
  description = "High IOPS PL1, PL2 and PL3 disks are costly and their usage should be reviewed."
  severity    = "low"

  sql = <<-EOQ
    select
      arn as resource,
      case
        when category <> 'cloud_essd' then 'skip'
        when iops > $1 then 'alarm'
        else 'ok'
      end as status,
      case
        when category <> 'cloud_essd' then title || ' is of type ' || category || '.'
        else title || ' with performance category ' || performance_level || ' has ' || iops || ' iops.'
      end as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      alicloud_ecs_disk;
  EOQ

  param "ecs_disk_max_iops" {
    description = "The maximum IOPS allowed for disks."
    default     = var.ecs_disk_max_iops
  }

  tags = merge(local.ecs_common_tags, {
    class = "deprecated"
  })
}

control "ecs_instance_with_low_utilization" {
  title       = "ECS instances with very low CPU utilization should be reviewed"
  description = "Resize or eliminate underutilized instances."
  severity    = "low"

  sql = <<-EOQ
    with ec2_instance_utilization as (
      select
        instance_id,
        round(cast(sum(maximum)/count(maximum) as numeric), 1) as avg_max,
        count(maximum) days
      from
        alicloud_ecs_instance_metric_cpu_utilization_daily
      where
        date_part('day', now() - timestamp) <=30
      group by
        instance_id
    )
    select
      arn as resource,
      case
        when avg_max is null then 'error'
        when avg_max < $1 then 'alarm'
        when avg_max < $2 then 'info'
        else 'ok'
      end as status,
      case
        when avg_max is null then 'Cloud monitor metrics not available for ' || title || '.'
        else title || ' is averaging ' || avg_max || '% max utilization over the last ' || days || ' days.'
      end as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      alicloud_ecs_instance as i
      left join ec2_instance_utilization as u on u.instance_id = i.instance_id;
  EOQ

  param "ecs_instance_avg_cpu_utilization_low" {
    description = "The average CPU utilization required for instances to be considered infrequently used. This value should be lower than ecs_instance_avg_cpu_utilization_high."
    default     = var.ecs_instance_avg_cpu_utilization_low
  }

  param "ecs_instance_avg_cpu_utilization_high" {
    description = "The average CPU utilization required for instances to be considered frequently used. This value should be higher than ecs_instance_avg_cpu_utilization_low."
    default     = var.ecs_instance_avg_cpu_utilization_high
  }

  tags = merge(local.ecs_common_tags, {
    class = "unused"
  })
}
