## Thrifty ECS Benchmark

Thrifty developers eliminate their unused and under-utilized ECS instances. This benchmark focuses on finding resources that have not been restarted recently, have old snapshots and have large, unused or inactive disks.

## Variables

| Variable | Description | Default |
| - | - | - |
| ecs_disk_max_iops | The maximum IOPS allowed for disks. | 32000 IOPS |
| ecs_disk_max_size_gb | The maximum size in GB allowed for disks. | 100 GB |
| ecs_instance_allowed_types | A list of allowed instance types. PostgreSQL wildcards are supported. | ["%.nano", "%.small", "%._large", ".__large"] |
| ecs_instance_avg_cpu_utilization_low | The average CPU utilization required for instances to be considered infrequently used. This value should be lower than `ecs_instance_avg_cpu_utilization_high`. | 20% |
| ecs_instance_avg_cpu_utilization_high | The average CPU utilization required for instances to be considered frequently used. This value should be higher than `ecs_instance_avg_cpu_utilization_low`. | 35% |
| ecs_running_instance_age_max_days | The maximum number of days instances are allowed to run. | 90 days |
| ecs_snapshot_age_max_days | The maximum number of days snapshots can be retained. | 90 days |
