## Thrifty ECS Benchmark

Thrifty developers eliminate their unused and under-utilized ECS instances. This benchmark focuses on finding resources that have not been restarted recently, have old snapshots and have large, unused or inactive disks.

## Variables

| Variable | Description | Default |
| - | - | - |
| ecs_disk_max_iops | The maximum IOPS allowed for disks. | 32000 IOPS |
| ecs_disk_max_size_gb | The maximum size in GB allowed for disks. | 100 GB |
| ecs_running_instance_age_max_days | The maximum number of days an instance can be running for. | 90 days |
| ecs_snapshot_age_max_days | The maximum number of days a snapshot can be retained for. | 90 days |

<!--- TODO --->
<!--- Use variables for instance type and instance low utilization --->
