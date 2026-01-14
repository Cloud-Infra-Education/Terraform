resource "aws_lambda_function" "alert_service" {
  function_name = "ott-alert-service"
  package_type  = "Image"
  image_uri     = "${var.ecr_url_alert}:v1"
  role          = aws_iam_role.alert_exec.arn

  environment {
    variables = {
      SECRET_NAME = var.slack_secret_name
    }
  }
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert_service.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.db_alarm_topic.arn
}

