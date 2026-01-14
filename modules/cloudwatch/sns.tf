resource "aws_sns_topic" "db_alarm_topic" {
  name = "${var.our_team}-db-alarm-topic"
}

resource "aws_sns_topic_subscription" "alert_sub" {
  topic_arn = aws_sns_topic.db_alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alert_service.arn
}
