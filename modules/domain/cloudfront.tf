locals {
  www_fqdn       = "${var.www_subdomain}.${var.domain_name}"
  s3_rest_domain = "${var.origin_bucket_name}.s3.${var.origin_bucket_region}.amazonaws.com"
  origin_id      = "${var.our_team}-origin-s3"
}


# CloudFront OAC 설정
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "y2om-oac-for-cloudfront"
  description                       = "S3보안을 위한 CloudFront 접속용 OAC "
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

  web_acl_id = var.cloudfront_waf_web_acl_arn

  origin {
    domain_name              = local.s3_rest_domain
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]
    compress        = true

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

  depends_on = [aws_acm_certificate_validation.www]
}

# =========
data "aws_iam_policy_document" "s3_allow_cloudfront" {
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
}

resource "aws_s3_bucket_policy" "this" {
  provider = aws.seoul
  bucket   = var.origin_bucket_name
  policy   = data.aws_iam_policy_document.s3_allow_cloudfront.json
}
