data "aws_iam_policy_document" "dms_assume" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["dms.amazonaws.com"]
    }
  }
}

# NOTE
# - AWS DMS는 계정 내에 아래 2개 Role이 존재해야 VPC/SubnetGroup 을 정상 처리합니다.
# - 이미 계정에 존재하면 create_iam_roles=false 로 비활성화하세요.

resource "aws_iam_role" "dms_vpc_role" {
  count              = var.create_iam_roles ? 1 : 0
  name               = "dms-vpc-role"
  assume_role_policy = data.aws_iam_policy_document.dms_assume.json
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role" {
  count      = var.create_iam_roles ? 1 : 0
  role       = aws_iam_role.dms_vpc_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

resource "aws_iam_role" "dms_cloudwatch_logs_role" {
  count              = var.create_iam_roles ? 1 : 0
  name               = "dms-cloudwatch-logs-role"
  assume_role_policy = data.aws_iam_policy_document.dms_assume.json
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_logs_role" {
  count      = var.create_iam_roles ? 1 : 0
  role       = aws_iam_role.dms_cloudwatch_logs_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

