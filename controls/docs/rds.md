## Thrifty RDS Benchmark

Thrifty developers check long running RDS database instances have the correct billing type and have recent connections.

## Variables

| Variable | Description | Default |
| - | - | - |
| rds_db_instance_age_max_days | The maximum number of days DB instances are allowed to run. | 90 days |
| rds_db_instance_age_warning_days | The number of days DB instances can be running before warning. | 30 days |
| rds_db_instance_avg_connections | The minimum number of average connections per day required for DB instances to be considered in-use. | 2 connections/day |
