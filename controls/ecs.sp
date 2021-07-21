locals {
  ecs_common_tags = merge(local.thrifty_common_tags, {
    service = "ecs"
  })
}

benchmark "ecs" {
  title         = "ECS Checks"
  description   = "Thrifty developers eliminate unused and under-utilized ECS resources."
  documentation = file("./controls/docs/ecs.md")
  tags          = local.ecs_common_tags
  children = [
    control.ecs_disk_attached_stopped_instance,
    control.ecs_disk_high_iops,
    control.ecs_disk_large,
    control.ecs_disk_unattached,
    control.ecs_instance_large,
    control.ecs_instance_long_running,
    control.ecs_snapshot_age_90
  ]
}

control "ecs_disk_attached_stopped_instance" {
  title       = "Disks attached to stopped instance should be reviewed"
  description = "Instances that are stopped may no longer need any disks attached."
  severity    = "low"

  sql = <<-EOT
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
      end as reason,
      d.region,
      d.account_id
    from
      alicloud_ecs_disk as d
      left join alicloud_ecs_instance as i on d.instance_id = i.instance_id;
  EOT

  tags = merge(local.ecs_common_tags, {
    class = "deprecated"
  })
}

control "ecs_disk_large" {
  title       = "Disks with over 100 GB should be resized if too large"
  description = "Large disks are unusual, expensive and should be reviewed."
  severity    = "low"

  sql = <<-EOT
    select
      arn as resource,
      case
        when size <= 100 then 'ok'
        else 'alarm'
      end as status,
      disk_id || ' is ' || size || ' GiB.' as reason,
      region,
      account_id
    from
      alicloud_ecs_disk;
  EOT

  tags = merge(local.ecs_common_tags, {
    class = "deprecated"
  })
}

control "ecs_disk_unattached" {
  title       = "Unused disks should be removed"
  description = "Unattached disks are charged by Alicloud, they should be removed unless there is a business need to retain them."
  severity    = "low"

  sql = <<-EOT
    select
      arn as resource,
      case
        when status = 'Available' then 'alarm'
        else 'ok'
      end as status,
      case
        when status = 'Available' then title || ' has no attachment.'
        else title || ' has attachment.'
      end as reason,
      region,
      account_id
    from
      alicloud_ecs_disk;
  EOT

  tags = merge(local.ecs_common_tags, {
    class = "unused"
  })
}

control "ecs_instance_large" {
  title       = "ECS instances of type 12xlarge or higher should be reviewed"
  description = "Large ECS instances are unusual, expensive and should be reviewed."
  severity    = "low"

  sql = <<-EOT
    select
      arn as resource,
      case
        when status not in ('Running', 'Pending', 'Starting') then 'info'
        when instance_type like '%.__xlarge' then 'alarm'
        else 'ok'
      end as status,
      title || ' has type ' || instance_type || ' and is ' || status || '.' as reason,
      region,
      account_id
    from
      alicloud_ecs_instance;
  EOT

  tags = merge(local.ecs_common_tags, {
    class = "deprecated"
  })
}

control "ecs_instance_long_running" {
  title       = "Long running instances should be reviewed"
  description = "Instances should ideally be ephemeral and rehydrated frequently, check why these instances have been running for so long."
  severity    = "low"

  sql = <<-EOT
    select
      arn as resource,
      case
        when date_part('day', now() - creation_time) > 90 then 'alarm'
        else 'ok'
      end as status,
      title || ' has been running ' || date_part('day', now() - creation_time) || ' days.' as reason,
      region,
      account_id
    from
      alicloud_ecs_instance
    where
      status in ('Running', 'Pending');
  EOT

  tags = merge(local.ecs_common_tags, {
    class = "deprecated"
  })
}

control "ecs_snapshot_age_90" {
  title       = "Snapshots created over 90 days ago should be deleted if not required"
  description = "Old snapshots are likely unneeded and costly to maintain."
  severity    = "low"

  sql = <<-EOT
    select
      'acs:acs:' || region || ':' || account_id || ':' || 'snapshot/' || snapshot_id as resource,
      case
        when creation_time > current_timestamp - interval '90 days' then 'ok'
        else 'alarm'
      end as status,
      snapshot_id || ' created at ' || creation_time || '(' || date_part('day', now() - creation_time) || ' days).'
      as reason,
      region,
      account_id
    from
      alicloud_ecs_snapshot;
  EOT

  tags = merge(local.ecs_common_tags, {
    class = "unused"
  })
}

control "ecs_disk_high_iops" {
  title         = "Which ECS disks are allocated for > 32k IOPS?"
  description   = "High IOPS PL1, PL2 and PL3 disks are costly and usage should be reviewed."
  severity      = "low"

  sql = <<-EOT
    select
      arn as resource,
      case
        when category <> 'cloud_essd' then 'skip'
        when iops > 32000 then 'alarm'
        else 'ok'
      end as status,
      case
        when category <> 'cloud_essd' then title || ' is of type ' || category || '.'
        else title || ' with performance category ' || performance_level || ' has ' || iops || ' iops.'
      end as reason,
      region,
      account_id
    from
      alicloud_ecs_disk;
  EOT

  tags = merge(local.ecs_common_tags, {
    class = "deprecated"
  })
}