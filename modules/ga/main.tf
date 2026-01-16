data "aws_lb" "seoul" {
  provider = aws.seoul

  tags = {
    (var.alb_lookup_tag_key) = var.alb_lookup_tag_value
  }
}

data "aws_lb" "oregon" {
  provider = aws.oregon

  tags = {
    (var.alb_lookup_tag_key) = var.alb_lookup_tag_value
  }
}

resource "aws_globalaccelerator_accelerator" "this" {
  name            = var.ga_name
  enabled         = var.enabled
  ip_address_type = var.ip_address_type
}

# =====================================
# TCP 80 포트 리스너는 제거됨 (ALB가 443만 리스닝하므로 불필요)
# =====================================

# ========================
# TCP 443 포트 리스너 추가 
# ======================== 
resource "aws_globalaccelerator_listener" "this" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  protocol        = var.listener_protocol
  client_affinity = var.client_affinity

  port_range {
    from_port = var.listener_port
    to_port   = var.listener_port
  }
}

resource "aws_globalaccelerator_endpoint_group" "seoul" {
  listener_arn          = aws_globalaccelerator_listener.this.id
  endpoint_group_region = var.seoul_region

  traffic_dial_percentage = var.traffic_dial_percentage

  health_check_protocol = "TCP"
  health_check_port     = 443

  endpoint_configuration {
    endpoint_id = data.aws_lb.seoul.arn
    weight      = var.seoul_weight
  }
}

resource "aws_globalaccelerator_endpoint_group" "oregon" {
  listener_arn          = aws_globalaccelerator_listener.this.id
  endpoint_group_region = var.oregon_region

  traffic_dial_percentage = var.traffic_dial_percentage

  health_check_protocol = "TCP"
  health_check_port     = 443

  endpoint_configuration {
    endpoint_id = data.aws_lb.oregon.arn
    weight      = var.oregon_weight
  }
}

