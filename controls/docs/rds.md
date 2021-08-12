## Thrifty RDS Benchmark

Thrifty developers check long running RDS database instances have the correct billing type and have recent connections.

### Default Thresholds

- [Long running RDS database instance threshold (90 Days)](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/controls/control.rds_db_instance_long_running)
- [Low connection RDS database instance threshold (2 Max connections per day)](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/controls/control.rds_db_instance_low_connection_count)
