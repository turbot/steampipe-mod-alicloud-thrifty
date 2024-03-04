// Benchmarks and controls for specific services should override the "service" tag
locals {
  alicloud_thrifty_common_tags = {
    category = "Cost"
    plugin   = "alicloud"
    service  = "AliCloud"
  }
}

variable "common_dimensions" {
  type        = list(string)
  description = "A list of common dimensions to add to each control."
  # Define which common dimensions should be added to each control.
  # - account_id
  # - connection_name (_ctx ->> 'connection_name')
  # - region
  default     = [ "account_id", "region" ]
}

variable "tag_dimensions" {
  type        = list(string)
  description = "A list of tags to add as dimensions to each control."
  # A list of tag names to include as dimensions for resources that support
  # tags (e.g. "Owner", "Environment"). Default to empty since tag names are
  # a personal choice.
  default     = []
}

locals {

  common_dimensions_qualifier_sql = <<-EOQ
  %{~ if contains(var.common_dimensions, "connection_name") }, __QUALIFIER___ctx ->> 'connection_name'%{ endif ~}
  %{~ if contains(var.common_dimensions, "account_id") }, __QUALIFIER__account_id%{ endif ~}
  %{~ if contains(var.common_dimensions, "region") }, __QUALIFIER__region%{ endif ~}
  EOQ

  tag_dimensions_qualifier_sql = <<-EOQ
  %{~ for dim in var.tag_dimensions },  __QUALIFIER__tags ->> '${dim}' as "${replace(dim, "\"", "\"\"")}"%{ endfor ~} 
  EOQ

}

locals {
  # Local internal variable with the full SQL select clause for common
  # and tag dimensions. Do not edit directly.
  common_dimensions_sql = replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "")
  tag_dimensions_sql = replace(local.tag_dimensions_qualifier_sql, "__QUALIFIER__", "")
}

mod "alicloud_thrifty" {
  # hub metadata
  title         = "Alibaba Cloud Thrifty"
  description   = "Are you a Thrifty Alibaba Cloud developer? This mod checks your Alibaba account(s) to check for unused and under utilized resources using Powerpipe and Steampipe."
  color         = "#FF6600"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/alicloud-thrifty.svg"
  categories    = ["alicloud", "cost", "thrifty", "public cloud"]

  opengraph {
    title       = "Thrifty mod for Alibaba Cloud"
    description = "Are you a Thrifty Alibaba Cloud dev? This mod checks your Alibaba Cloud account(s) for unused and under-utilized resources using Powerpipe and Steampipe."
    image       = "/images/mods/turbot/alicloud-thrifty-social-graphic.png"
  }
}
