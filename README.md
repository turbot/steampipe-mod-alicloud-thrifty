# Alibaba Cloud Thrifty

An Alibaba Cloud cost savings and waste checking tool.

## Quick start

1) Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```shell
brew tap turbot/tap
brew install steampipe

steampipe -v
steampipe version 0.7.0
```

Install the Alibaba Cloud plugin
```shell
steampipe plugin install alicloud
```

Clone this repo and move into the directory:
```sh
git clone git@github.com:turbot/steampipe-mod-alicloud-thrifty
cd steampipe-mod-alicloud-thrifty
```

Run all benchmarks:
```shell
steampipe check all
```

![image](https://github.com/turbot/steampipe-mod-alicloud-thrifty/blob/main/docs/thrifty-output.png?raw=true)

Your can also run a specific controls:
```shell
steampipe check control.ecs_instance_with_low_utilization
```

## Current Thrifty Checks

- Underused **RDS Databases**
- Unused, underused and oversized **ECS Instances**
- Unused, underused and oversized **ECS Disks** and **Snapshots**
- **OSS Buckets** without lifecycle policies
- Unattached **Elastic IPs**
- Unused **VPC NAT Gateways**
- [#TODO List](https://github.com/turbot/steampipe-mod-alicloud-thrifty/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)

**Use introspection to view the available controls:**:
```
steampipe query "select resource_name from steampipe_control;"
```

## Contributing

Have an idea for a thrifty check but aren't sure how to get started?
- **[Join our Slack community →](https://join.slack.com/t/steampipe/shared_invite/zt-oij778tv-lYyRTWOTMQYBVAbtPSWs3g)**
- **[Mod developer guide →](https://steampipe.io/docs/steampipe-mods/writing-mods.md)**

**Prerequisites**:
- [Steampipe installed](https://steampipe.io/downloads)
- Steampipe Alibaba Cloud plugin installed (see above)

**Fork**:
Click on the GitHub Fork Widget. (Don't forget to :star: the repo!)

**Clone**:

1. Change the current working directory to the location where you want to put the cloned directory on your local filesystem.
2. Type the clone command below inserting your GitHub username instead of `YOUR-USERNAME`:

```sh
git clone git@github.com:YOUR-USERNAME/steampipe-mod-alicloud-thrifty
cd steampipe-mod-alicloud-thrifty
```

Thanks for getting involved! We would love to have you [join our Slack community](https://join.slack.com/t/steampipe/shared_invite/zt-oij778tv-lYyRTWOTMQYBVAbtPSWs3g) and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-alicloud-thrifty/blob/main/LICENSE).

`help wanted` issues:
- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [Alibaba Cloud Thrifty Mod](https://github.com/turbot/steampipe-mod-alicloud-thrifty/labels/help%20wanted)
