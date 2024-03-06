## v0.8 [2024-04-06]

_Powerpipe_

[Powerpipe](https://powerpipe.io) is now the preferred way to run this mod!  [Migrating from Steampipe →](https://powerpipe.io/blog/migrating-from-steampipe)

All v0.x versions of this mod will work in both Steampipe and Powerpipe, but v1.0.0 onwards will be in Powerpipe format only.

_Enhancements_

- Focus documentation on Powerpipe commands.
- Show how to combine Powerpipe mods with Steampipe plugins.

## v0.7 [2023-02-10]

_What's new?_

- Added `tags` as dimensions to group and filter findings. (see [var.tag_dimensions](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/variables)) ([#34](https://github.com/turbot/steampipe-mod-alicloud-thrifty/pull/34))
- Added `connection_name` in the common dimensions to group and filter findings. (see [var.common_dimensions](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/variables)) ([#34](https://github.com/turbot/steampipe-mod-alicloud-thrifty/pull/34))

## v0.6 [2022-05-09]

_Enhancements_

- Updated docs/index.md and README with new dashboard screenshots and latest format. ([#29](https://github.com/turbot/steampipe-mod-alicloud-thrifty/pull/29))

## v0.5 [2022-05-05]

_Enhancements_

- Added `category`, `service`, and `type` tags to benchmarks and controls. ([#25](https://github.com/turbot/steampipe-mod-alicloud-thrifty/pull/25))

## v0.4 [2022-03-29]

_What's new?_

- Added default values to all variables (set to the same values in `steampipe.spvars.example`)
- Added `*.spvars` and `*.auto.spvars` files to `.gitignore`
- Renamed `steampipe.spvars` to `steampipe.spvars.example`, so the variable default values will be used initially. To use this example file instead, copy `steampipe.spvars.example` as a new file `steampipe.spvars`, and then modify the variable values in it. For more information on how to set variable values, please see [Input Variable Configuration](https://hub.steampipe.io/mods/turbot/alicloud_thrifty#configuration).

_Bug fixes_

- Fixed the `ecs_instance_long_running` control to only evaluate instances which are in the running state ([#19](https://github.com/turbot/steampipe-mod-alicloud-thrifty/pull/19))

## v0.3 [2021-09-29]

_What's new?_

- Added: Input variables have been added to ECS and RDS controls to allow different thresholds to be passed in. To get started, please see [Alicloud Thrifty Configuration](https://hub.steampipe.io/mods/turbot/alicloud_thrifty#configuration). For a list of variables and their default values, please see [steampipe.spvars](https://github.com/turbot/steampipe-mod-alicloud-thrifty/blob/main/steampipe.spvars).

## v0.2 [2021-09-23]

_Enhancements_

- Updated: GitHub repository cloning instructions in README.md and docs/index.md now use HTTPS instead of SSH

## v0.1 [2021-08-12]

_What's new?_

- Added initial ActionTrail, ECS, OSS, RDS and VPC benchmarks
