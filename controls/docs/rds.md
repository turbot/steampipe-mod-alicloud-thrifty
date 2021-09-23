## Thrifty RDS Benchmark

Thrifty developers check long running RDS database instances have the correct billing type and have recent connections.

## Variables

| Variable | Description | Default |
| - | - | - |
| rds_db_instance_age_max_days | The maximum number of days a DB instance can be running for. | 90 days |
| rds_db_instance_age_warning_days | The maximum number of days set as warning threshold for a DB instance. | 30 days |
| rds_db_instance_min_connection_per_day | The minimum number of connections/day a DB instance can be processed. | 2 connections/day |
