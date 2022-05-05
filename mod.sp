// Benchmarks and controls for specific services should override the "service" tag
locals {
  alicloud_thrifty_common_tags = {
    category = "Cost"
    plugin   = "alicloud"
    service  = "AliCloud"
  }
}

mod "alicloud_thrifty" {
  # hub metadata
  title         = "Alibaba Cloud Thrifty"
  description   = "Are you a Thrifty Alibaba Cloud developer? This Steampipe mod checks your Alibaba account(s) to check for unused and under utilized resources."
  color         = "#FF6600"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/alicloud-thrifty.svg"
  categories    = ["alicloud", "cost", "thrifty", "public cloud"]

  opengraph {
    title       = "Thrifty mod for Alibaba Cloud"
    description = "Are you a Thrifty Alibaba Cloud dev? This Steampipe mod checks your Alibaba Cloud account(s) for unused and under-utilized resources."
    image       = "/images/mods/turbot/alicloud-thrifty-social-graphic.png"
  }
}
