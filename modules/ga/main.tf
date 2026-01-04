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
# TCP 80 포트 리스너 추가 (나중에 삭제)
# =====================================
resource "aws_globalaccelerator_listener" "http" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  protocol        = var.http_listener_protocol
  client_affinity = var.http_client_affinity

  port_range {
    from_port = var.http_listener_port
    to_port   = var.http_listener_port
  }
}

resource "aws_globalaccelerator_endpoint_group" "seoul_http" {
  listener_arn         = aws_globalaccelerator_listener.http.id
  endpoint_group_region = var.seoul_region

  traffic_dial_percentage = var.http_traffic_dial_percentage

  health_check_protocol = var.http_health_check_protocol
  health_check_port     = var.http_health_check_port

  endpoint_configuration {
    endpoint_id = data.aws_lb.seoul.arn
    weight      = var.seoul_weight
  }
}

resource "aws_globalaccelerator_endpoint_group" "oregon_http" {
  listener_arn         = aws_globalaccelerator_listener.http.id
  endpoint_group_region = var.oregon_region

  traffic_dial_percentage = var.http_traffic_dial_percentage

  health_check_protocol = var.http_health_check_protocol
  health_check_port     = var.http_health_check_port

  endpoint_configuration {
    endpoint_id = data.aws_lb.oregon.arn
    weight      = var.oregon_weight
  }
}



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

  health_check_protocol = var.health_check_protocol
  health_check_port     = var.health_check_port

  endpoint_configuration {
    endpoint_id = data.aws_lb.seoul.arn
    weight      = var.seoul_weight
  }
}

resource "aws_globalaccelerator_endpoint_group" "oregon" {
  listener_arn          = aws_globalaccelerator_listener.this.id
  endpoint_group_region = var.oregon_region

  traffic_dial_percentage = var.traffic_dial_percentage

  health_check_protocol = var.health_check_protocol
  health_check_port     = var.health_check_port

  endpoint_configuration {
    endpoint_id = data.aws_lb.oregon.arn
    weight      = var.oregon_weight
  }
}

