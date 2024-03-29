locals {
  oss_common_tags = merge(local.alicloud_thrifty_common_tags, {
    service = "AliCloud/OSS"
  })
}

benchmark "oss" {
  title         = "OSS Checks"
  description   = "Thrifty developers ensure their OSS buckets have managed lifecycle policies."
  documentation = file("./controls/docs/oss.md")
  children = [
    control.oss_bucket_without_lifecycle_policy
  ]

  tags = merge(local.oss_common_tags, {
    type = "Benchmark"
  })
}

control "oss_bucket_without_lifecycle_policy" {
  title       = "OSS buckets should have lifecycle policies"
  description = "Buckets should have a lifecycle policy associated for data retention."
  severity    = "low"

  sql = <<-EOQ
    select
      arn as resource,
      case
        when lifecycle_rules is null then 'alarm'
        when lifecycle_rules @> '[{"Status":"Enabled"}]' then 'ok'
        else 'alarm'
      end as status,
      case
        when lifecycle_rules is null then title || ' has no lifecycle policy.'
        when lifecycle_rules @> '[{"Status":"Enabled"}]' then title || ' has lifecycle policy.'
        else title || ' has disabled lifecycle policy.'
      end as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      alicloud_oss_bucket;
  EOQ

  tags = merge(local.oss_common_tags, {
    class = "managed"
  })
}
