## Thrifty ECS Benchmark

Thrifty developers eliminate their unused and under-utilized ECS instances. This benchmark focuses on finding resources that have not been restarted recently, have old snapshots and have large, unused or inactive disks.

### Default Thresholds

- Disks that are large (> 100 GB)
- Snapshot age threshold (90 days)
- Long running virtual machine threshold (90 days)