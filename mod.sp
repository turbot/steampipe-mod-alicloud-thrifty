// Benchmarks and controls for specific services should override the "service" tag
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
