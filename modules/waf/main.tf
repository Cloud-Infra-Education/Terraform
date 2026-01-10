locals {
  raw_name = "${var.our_team}-${var.domain_name}"

  name_base = replace(local.raw_name, "/[^0-9A-Za-z_-]/", "-")

  metric_base = substr(
    replace("waf-${local.name_base}", "/[^0-9A-Za-z_-]/", "-"),
    0,
    80
  )
}


# =========================================================
# CloudFront용 WAFv2 WebACL (scope = CLOUDFRONT / us-east-1)
# =========================================================
resource "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.acm

  name  = "${local.name_base}-cloudfront-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = substr("${local.metric_base}-CloudFrontWAF", 0, 128)
    sampled_requests_enabled   = true
  }
  
  #
  rule {
    name     = "AllowOnlyKRUS"
    priority = 0
    action { 
      block {} 
    }
    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = ["KR", "US"]
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowOnlyKRUS"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = substr("${local.metric_base}-CFR-Common", 0, 128)
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = substr("${local.metric_base}-CFR-IpRep", 0, 128)
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = substr("${local.metric_base}-CFR-BadInputs", 0, 128)
      sampled_requests_enabled   = true
    }
  }
}

# =====================================
# Seoul ALB용 WAFv2 WebACL (scope=REGIONAL)
# =====================================
resource "aws_wafv2_web_acl" "seoul" {
  provider = aws.seoul

  name  = "${local.name_base}-seoul-alb-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = substr("${local.metric_base}-SeoulALBWAF", 0, 128)
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = substr("${local.metric_base}-Seoul-Common", 0, 128)
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = substr("${local.metric_base}-Seoul-IpRep", 0, 128)
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = substr("${local.metric_base}-Seoul-BadInputs", 0, 128)
      sampled_requests_enabled   = true
    }
  }
}

# ======================================
# Oregon ALB용 WAFv2 WebACL (scope=REGIONAL)
# ======================================
resource "aws_wafv2_web_acl" "oregon" {
  provider = aws.oregon

  name  = "${local.name_base}-oregon-alb-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = substr("${local.metric_base}-OregonALBWAF", 0, 128)
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = substr("${local.metric_base}-Oregon-Common", 0, 128)
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = substr("${local.metric_base}-Oregon-IpRep", 0, 128)
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = substr("${local.metric_base}-Oregon-BadInputs", 0, 128)
      sampled_requests_enabled   = true
    }
  }
}

