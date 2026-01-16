# ============= Bastion IAM Role for SSM (EC2 Instance Connect) =============

resource "aws_iam_role" "bastion_ssm" {
  name = "${var.name}-bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.name}-bastion-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# S3 읽기 권한 추가 (Backend 코드 다운로드용)
resource "aws_iam_role_policy" "bastion_s3_read" {
  name = "${var.name}-bastion-s3-read"
  role = aws_iam_role.bastion_ssm.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::y2om-my-origin-bucket-123456",
        "arn:aws:s3:::y2om-my-origin-bucket-123456/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "bastion_ssm" {
  name = "${var.name}-bastion-ssm-profile"
  role = aws_iam_role.bastion_ssm.name

  tags = {
    Name = "${var.name}-bastion-ssm-profile"
  }
}
