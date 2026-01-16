locals {
  www_fqdn = "${var.www_subdomain}.${var.domain_name}"
  s3_rest_domain    = "${var.origin_bucket_name}.s3.${var.origin_bucket_region}.amazonaws.com"
  origin_id         = "${var.our_team}-origin-s3"
}


# CloudFront OAC 설정
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "oac-for-cloudfront"
  description                       = "S3보안을 위한 CloudFront 접속용 OAC "
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "www" {
  enabled             = true
  is_ipv6_enabled      = true
  default_root_object = var.default_root_object
  aliases             = [local.www_fqdn]
  price_class         = "PriceClass_All"

<<<<<<< Updated upstream
  web_acl_id = var.cloudfront_waf_web_acl_arn
=======
  # 1) [수정] CloudFront Access Logs -> 전용 로그 버킷으로 변경
  logging_config {
    include_cookies = false
    # 기존 origin_bucket_name 대신 log_bucket_name을 사용합니다.
    bucket          = "${var.log_bucket_name}.s3.amazonaws.com"
    prefix          = "cf-access-logs/"
  }
>>>>>>> Stashed changes

  origin {
    domain_name = local.s3_rest_domain
    origin_id   = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    
    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    compress         = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 60
    max_ttl     = 300
  }

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

<<<<<<< Updated upstream
  depends_on = [aws_acm_certificate_validation.www]
}

# =========
data "aws_iam_policy_document" "s3_allow_cloudfront" {
=======
# 2) CloudFront 모니터링: 5xx 에러율 알람
resource "aws_cloudwatch_metric_alarm" "cf_5xx_error_rate" {
  alarm_name          = "${var.our_team}-cf-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name          = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"
  alarm_description   = "CloudFront 5xx error rate is above 5%"
  dimensions = {
    DistributionId = aws_cloudfront_distribution.www.id
    Region         = "Global"
  }
}

# 3) [분리] S3 원본 버킷 정책: CloudFront OAC 전용
data "aws_iam_policy_document" "origin_bucket_policy" {
>>>>>>> Stashed changes
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]

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
<<<<<<< Updated upstream
}

resource "aws_s3_bucket_policy" "this" {
  provider = aws.seoul
  bucket = var.origin_bucket_name
  policy = data.aws_iam_policy_document.s3_allow_cloudfront.json
=======
}

# 4) [분리] S3 로그 버킷 정책: 로그 전달 서비스 전용
data "aws_iam_policy_document" "log_bucket_policy" {
  statement {
    sid     = "AllowLogDeliveryWrite"
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${var.log_bucket_name}/cf-access-logs/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid     = "AllowLogDeliveryAclCheck"
    actions = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${var.log_bucket_name}"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

# [적용] 원본 버킷 정책 적용
resource "aws_s3_bucket_policy" "origin" {
  provider = aws.seoul
  bucket   = var.origin_bucket_name
  policy   = data.aws_iam_policy_document.origin_bucket_policy.json
}

# [적용] 로그 버킷 정책 적용
resource "aws_s3_bucket_policy" "log" {
  provider = aws.seoul
  bucket   = var.log_bucket_name
  policy   = data.aws_iam_policy_document.log_bucket_policy.json
>>>>>>> Stashed changes
}
