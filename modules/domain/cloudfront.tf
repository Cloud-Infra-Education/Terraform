locals {
  www_fqdn       = "${var.www_subdomain}.${var.domain_name}"
  s3_rest_domain = "${var.origin_bucket_name}.s3.${var.origin_bucket_region}.amazonaws.com"
  origin_id      = "${var.our_team}-origin-s3"
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "oac-for-cloudfront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "www" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  aliases             = [local.www_fqdn]
  price_class         = "PriceClass_All"
  web_acl_id          = var.cloudfront_waf_web_acl_arn

  # 1) CloudFront Access Logs -> S3
  logging_config {
    include_cookies = false
    bucket          = "${var.origin_bucket_name}.s3.amazonaws.com"
    prefix          = "cf-access-logs/"
  }

  origin {
    domain_name              = local.s3_rest_domain
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    # [수정] 세미콜론을 지우고 한 줄에 하나씩 배치했습니다.
    min_ttl     = 0
    default_ttl = 60
    max_ttl     = 300
  }

  # [수정] 중첩된 블록을 계단식으로 정렬했습니다.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.www.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# 2) CloudFront 모니터링: 5xx 에러율 알람
resource "aws_cloudwatch_metric_alarm" "cf_5xx_error_rate" {
  alarm_name          = "${var.our_team}-cf-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "60"
  statistic           = "Average"
  threshold           = "5" # 5% 이상 시 알람
  alarm_description   = "CloudFront 5xx error rate is above 5%"
  dimensions = {
    DistributionId = aws_cloudfront_distribution.www.id
    Region         = "Global"
  }
}

# 3) S3 Bucket Policy (OAC + Log Delivery)
data "aws_iam_policy_document" "s3_combined_policy" {
  statement {
    sid       = "AllowCloudFrontOAC"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.origin_bucket_name}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.www.arn]
    }
  }

  statement {
    sid     = "AllowLogDeliveryWrite"
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${var.origin_bucket_name}/cf-access-logs/*",
      "arn:aws:s3:::${var.origin_bucket_name}/ga-flow-logs/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid     = "AllowLogDeliveryAclCheck"
    actions = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${var.origin_bucket_name}"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

# [수정 핵심] S3 버킷은 서울에 있으므로 aws.seoul 프로바이더를 사용합니다.
resource "aws_s3_bucket_policy" "this" {
  provider = aws.seoul
  bucket   = var.origin_bucket_name
  policy   = data.aws_iam_policy_document.s3_combined_policy.json
}
