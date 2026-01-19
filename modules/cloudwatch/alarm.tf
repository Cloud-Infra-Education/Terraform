# RDS Aurora Cluster CPU 알람
resource "aws_cloudwatch_metric_alarm" "aurora_cluster_cpu_high" {
  alarm_name          = "OTT-Aurora-Cluster-CPU-Utilization-High"
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
    DBClusterIdentifier = var.aurora_cluster_id
  }

  alarm_description = "RDS Aurora Cluster CPU 사용률이 80% 이상 5분 지속 시 알람"
}

resource "aws_cloudwatch_metric_alarm" "aurora_cluster_memory_low" {
  alarm_name          = "OTT-Aurora-Cluster-FreeableMemory-Low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000000000"
  alarm_actions       = [aws_sns_topic.db_alarm_topic.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = var.aurora_cluster_id
  }

  alarm_description = "RDS Aurora Cluster 사용 가능한 메모리가 1GB 이하일 때 알람"
}

# RDS Aurora Cluster 연결 수 알람
resource "aws_cloudwatch_metric_alarm" "aurora_cluster_connections_high" {
  alarm_name          = "OTT-Aurora-Cluster-DatabaseConnections-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.db_alarm_topic.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = var.aurora_cluster_id
  }

  alarm_description = "RDS Aurora Cluster 데이터베이스 연결 수가 80 이상일 때 알람"
}

resource "aws_cloudwatch_metric_alarm" "eks_cluster_cpu_high" {
  alarm_name          = "OTT-EKS-Cluster-CPU-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "cluster_total_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.db_alarm_topic.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.eks_cluster_name
  }

  alarm_description = "EKS 클러스터 전체 CPU 사용률이 80% 이상일 때 알람"
}

resource "aws_cloudwatch_metric_alarm" "eks_cluster_memory_high" {
  alarm_name          = "OTT-EKS-Cluster-Memory-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "cluster_total_memory_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_actions       = [aws_sns_topic.db_alarm_topic.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.eks_cluster_name
  }

  alarm_description = "EKS 클러스터 전체 메모리 사용률이 85% 이상일 때 알람"
}

resource "aws_cloudwatch_metric_alarm" "eks_namespace_cpu_high" {
  alarm_name          = "OTT-EKS-Namespace-formation-lap-CPU-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "namespace_total_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  alarm_actions       = [aws_sns_topic.db_alarm_topic.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.eks_cluster_name
    Namespace    = "formation-lap"
  }

  alarm_description = "EKS formation-lap 네임스페이스 CPU 사용률이 75% 이상일 때 알람"
}

resource "aws_cloudwatch_metric_alarm" "eks_namespace_memory_high" {
  alarm_name          = "OTT-EKS-Namespace-formation-lap-Memory-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "namespace_total_memory_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.db_alarm_topic.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.eks_cluster_name
    Namespace    = "formation-lap"
  }

  alarm_description = "EKS formation-lap 네임스페이스 메모리 사용률이 80% 이상일 때 알람"
}
