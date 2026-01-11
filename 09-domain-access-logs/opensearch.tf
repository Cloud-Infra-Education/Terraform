# OpenSearch 도메인: DNS 로그 인덱싱 및 검색
resource "aws_opensearch_domain" "route53_logs" {
  domain_name    = var.opensearch_domain_name
  engine_version = var.opensearch_version

  cluster_config {
    instance_type  = var.opensearch_instance_type
    instance_count = var.opensearch_instance_count
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp3"
  }

  # 보안 설정: IAM 기반 접근 제어
  # Lambda 함수와 현재 AWS 계정의 IAM 사용자/역할이 접근 가능
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.lambda_exec_role.arn
        }
        Action   = "es:*"
        Resource = "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "es:*"
        Resource = "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"
      }
    ]
  })

  # 노드 간 암호화
  node_to_node_encryption {
    enabled = true
  }

  # 암호화 at rest
  encrypt_at_rest {
    enabled = true
  }

  # HTTPS 강제
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  # Fine-grained access control: 브라우저에서 직접 접근 가능하도록 활성화
  # 마스터 사용자: admin / 비밀번호: 변수로 설정
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "admin"
      master_user_password = var.opensearch_master_user_password
    }
  }

  tags = {
    Name = "Route53 DNS Logs"
  }

  depends_on = [aws_iam_service_linked_role.opensearch]
}

# OpenSearch 서비스 링크드 역할 (필요한 경우)
resource "aws_iam_service_linked_role" "opensearch" {
  count            = var.opensearch_create_service_linked_role ? 1 : 0
  aws_service_name = "opensearchservice.amazonaws.com"
}