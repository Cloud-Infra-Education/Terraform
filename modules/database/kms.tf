# 서울 CMK
resource "aws_kms_key" "aurora_seoul" {
  description             = "Aurora Global Cluster CMK - Seoul"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

# 오레곤 CMK
resource "aws_kms_key" "aurora_oregon" {
  provider                = aws.oregon
  description             = "Aurora Global Cluster CMK - Oregon"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

