# CPU 사용량 알람 (80% 이상 5분 지속)
resource "aws_cloudwatch_metric_alarm" "db_cpu_high" {
  alarm_name          = "OTT-DB-CPU-Utilization-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.db_alarm_topic.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

# 데이터베이스 연결 수 과다 알람 (연결 수 80개 이상)
resource "aws_cloudwatch_metric_alarm" "db_connections_high" {
  alarm_name          = "OTT-DB-Connections-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.db_alarm_topic.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}
