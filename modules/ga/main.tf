# 1. Global Accelerator 본체
resource "aws_globalaccelerator_accelerator" "this" {
  name            = var.ga_name
  ip_address_type = var.ip_address_type
  enabled         = var.enabled

  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = var.origin_bucket_name
    flow_logs_s3_prefix = "ga-flow-logs/"
  }
}

# ------------------------------------------------------------
# 2. 리스너 설정 (HTTPS 443 & HTTP 80)
# ------------------------------------------------------------
resource "aws_globalaccelerator_listener" "https" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  client_affinity = var.client_affinity
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_listener" "http" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  client_affinity = var.client_affinity
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

# 3. ALB 데이터 소스
data "aws_lb" "seoul_alb" {
  provider = aws.seoul
  tags = { (var.alb_lookup_tag_key) = var.alb_lookup_tag_value }
}

data "aws_lb" "oregon_alb" {
  provider = aws.oregon
  tags = { (var.alb_lookup_tag_key) = var.alb_lookup_tag_value }
}

# ------------------------------------------------------------
# 4. HTTPS(443) 리스너를 위한 엔드포인트 그룹
# ------------------------------------------------------------
resource "aws_globalaccelerator_endpoint_group" "seoul_443" {
  listener_arn = aws_globalaccelerator_listener.https.id
  endpoint_group_region = "ap-northeast-2"

  endpoint_configuration {
    endpoint_id = data.aws_lb.seoul_alb.arn
    weight      = var.seoul_weight
  }
}

resource "aws_globalaccelerator_endpoint_group" "oregon_443" {
  listener_arn = aws_globalaccelerator_listener.https.id
  endpoint_group_region = "us-west-2"

  endpoint_configuration {
    endpoint_id = data.aws_lb.oregon_alb.arn
    weight      = var.oregon_weight
  }
}

# ------------------------------------------------------------
# 5. HTTP(80) 리스너를 위한 엔드포인트 그룹 (복구!)
# ------------------------------------------------------------
resource "aws_globalaccelerator_endpoint_group" "seoul_80" {
  listener_arn = aws_globalaccelerator_listener.http.id
  endpoint_group_region = "ap-northeast-2"

  endpoint_configuration {
    endpoint_id = data.aws_lb.seoul_alb.arn
    weight      = var.seoul_weight
  }
}

resource "aws_globalaccelerator_endpoint_group" "oregon_80" {
  listener_arn = aws_globalaccelerator_listener.http.id
  endpoint_group_region = "us-west-2"

  endpoint_configuration {
    endpoint_id = data.aws_lb.oregon_alb.arn
    weight      = var.oregon_weight
  }
}
