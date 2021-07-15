locals {
  oss_common_tags = merge(local.thrifty_common_tags, {
    service = "oss"
  })
}

benchmark "oss" {
  title         = "OSS Checks"
  description   = "Thrifty developers ensure their OSS buckets have managed lifecycle policies."
  documentation = file("./controls/docs/oss.md")
  tags          = local.oss_common_tags
  children = [
    control.oss_bucket_without_lifecycle_policy
  ]
}

control "oss_bucket_without_lifecycle_policy" {
  title         = "OSS buckets should have lifecycle policies"
  description   = "Buckets should have a lifecycle policy associated for data retention."
  severity    = "low"

  sql = <<-EOT
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
        else title || ' has lifecycle policy, but disabled.'
      end as reason,
      region,
      account_id
    from
      alicloud_oss_bucket;
  EOT

  tags = merge(local.oss_common_tags, {
    class = "managed"
  })
}
