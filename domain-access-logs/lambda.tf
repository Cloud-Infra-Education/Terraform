# Lambda 함수 코드 압축
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda 함수
resource "aws_lambda_function" "route53_log_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 256
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      OPENSEARCH_ENDPOINT = aws_opensearch_domain.route53_logs.endpoint
      OPENSEARCH_INDEX    = var.opensearch_index_name
    }
  }

  tags = {
    Name = "y2om-Route53 DNS Log Processor"
  }
}

# CloudWatch Logs Subscription Filter: 로그가 들어오면 Lambda 트리거
# Subscription Filter는 로그 그룹과 같은 리전(us-east-1)에 생성해야 함
resource "aws_cloudwatch_log_subscription_filter" "lambda_trigger" {
  provider = aws.us_east_1

  name            = "y2om-route53-log-to-lambda"
  log_group_name  = aws_cloudwatch_log_group.route53_query_logs.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.route53_log_processor.arn

  depends_on = [
    aws_lambda_function.route53_log_processor,
    aws_lambda_permission.allow_cloudwatch_logs
  ]
}

# Lambda 권한: CloudWatch Logs가 Lambda를 호출할 수 있도록 허용
# Lambda는 크로스 리전 호출 가능 (us-east-1의 Logs가 서울의 Lambda 호출)
resource "aws_lambda_permission" "allow_cloudwatch_logs" {
  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.route53_log_processor.function_name
  principal     = "logs.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.route53_query_logs.arn}:*"
  source_account = data.aws_caller_identity.us_east_1.account_id
}