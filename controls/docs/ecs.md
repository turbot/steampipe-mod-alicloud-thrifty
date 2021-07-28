## Thrifty ECS Benchmark

Thrifty developers eliminate their unused and under-utilized ECS instances. This benchmark focuses on finding resources that have not been restarted recently, have old snapshots and have large, unused or inactive disks.

### Default Thresholds

- [Large ECS disk size threshold (100gb)](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/controls/control.ecs_disk_large)
- [Old ECS snapshot threshold (90 days)](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/controls/control.ecs_snapshot_age_90)
- [Long running ECS instance threshold (90 days)](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/controls/control.ecs_instance_long_running)
- [Low utilization ECS instance threshold (< 35%)](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/controls/control.ecs_instance_with_low_utilization)
- [High IOPS ECS disk threshold (32,000 IOPS)](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/controls/control.ecs_disk_high_iops)
- [ECS instance types that are too big (> 12xlarge)](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/controls/control.ecs_instance_large)