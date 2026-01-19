resource "aws_lambda_function" "alert_service" {
  function_name = "ott-alert-service"
  package_type  = "Image"
  image_uri     = "${var.ecr_url_alert}:alert-v1"  # ⭐ user-service 레지스토리의 alert-v1 태그 사용
  role          = aws_iam_role.alert_exec.arn
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      SECRET_NAME = var.slack_secret_name
      AWS_REGION  = "ap-northeast-2"
    }
  }

  # 이미지가 업데이트되면 Lambda도 업데이트
  image_config {
    command = ["app.handler"]
  }
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert_service.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.db_alarm_topic.arn
}

