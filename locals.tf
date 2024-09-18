locals  {
    rds_identifier = lower("rds${var.app_name}${var.environment}")
}    