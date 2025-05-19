# - terraform managed waf -

resource "aws_wafv2_web_acl" "terraform_managed" {
  count       = var.wafcharm_managed == false ? 1 : 0
  name        = var.name
  description = var.description
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  rule {
    name     = "rule-1"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_QUERYSTRING"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "NoUserAgent_HEADER"
        }

        scope_down_statement {
          geo_match_statement {
            country_codes = ["US", "NL"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }

  token_domains = ["mywebsite.com", "myotherwebsite.com"]

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}



# - wafcharm managed waf -
resource "aws_wafv2_web_acl" "wafcharm_managed" {
  count       = var.wafcharm_managed == true ? 1 : 0
  name        = var.name
  description = var.description
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }


  lifecycle {
    ignore_changes = [rule]
  }

  token_domains = ["mywebsite.com", "myotherwebsite.com"]

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}


# CloudWatch logging module
module "cloudwatch_logging" {
  count  = var.logging_dist_cloudwatch == true ? 1 : 0
  source = "./modules/logging_dist_cloudwatch"

  name               = var.name
  log_retention_days = var.log_retention_days
  log_class          = var.cloudwatch_log_class
  region             = data.aws_region.current.name
  account_id         = data.aws_caller_identity.current.account_id
}

# S3 logging module
module "s3_logging" {
  count  = var.logging_dist_s3 == true || (var.logging_dist_firehose == true && var.log_bucket_arn == "") ? 1 : 0
  source = "./modules/logging_dist_s3"

  name = var.name
}

# Firehose logging module
module "firehose_logging" {
  count  = var.logging_dist_firehose == true ? 1 : 0
  source = "./modules/logging_dist_firehose"

  name                       = var.name
  log_bucket_arn             = var.log_bucket_arn
  s3_bucket_arn              = var.logging_dist_s3 == true ? module.s3_logging[0].s3_bucket_arn : (var.log_bucket_arn == "" ? module.s3_logging[0].s3_bucket_arn : "")
  log_bucket_keys            = var.log_bucket_keys
  kms_key_arn                = var.kms_key_arn
  firehose_buffer_interval   = var.firehose_buffer_interval
  firehose_buffer_size       = var.firehose_buffer_size
  log_s3_prefix              = var.log_s3_prefix
  log_s3_error_output_prefix = var.log_s3_error_output_prefix
}



resource "aws_wafv2_web_acl_logging_configuration" "logging_conf" {
  count = (var.logging_dist_cloudwatch == true || var.logging_dist_s3 == true || var.logging_dist_firehose == true) ? 1 : 0

  log_destination_configs = compact([
    var.logging_dist_cloudwatch == true ? module.cloudwatch_logging[0].cloudwatch_log_group_arn : "",
    var.logging_dist_s3 == true ? module.s3_logging[0].s3_bucket_arn : "",
    var.logging_dist_firehose == true ? module.firehose_logging[0].firehose_delivery_stream_arn : ""
  ])

  resource_arn = var.wafcharm_managed == false ? aws_wafv2_web_acl.terraform_managed[0].arn : aws_wafv2_web_acl.wafcharm_managed[0].arn

  # Optional: Redacted fields configuration
  dynamic "redacted_fields" {
    for_each = var.redact_authorization_header ? [1] : []

    content {
      single_header {
        name = "authorization"
      }
    }
  }

  # Optional: Logging filter configuration
  dynamic "logging_filter" {
    for_each = var.enable_logging_filter ? [1] : []

    content {
      default_behavior = "KEEP"

      filter {
        behavior    = "DROP"
        requirement = "MEETS_ANY"
        condition {
          action_condition {
            action = "ALLOW"
          }
        }
      }
    }
  }
}
