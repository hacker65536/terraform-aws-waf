#------------------------------------------------------------------------------
# AWS WAF Module with Multiple Logging Options
#
# This module configures an AWS WAF Web ACL with support for multiple logging 
# destinations and KMS encryption options.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Local Variables
#------------------------------------------------------------------------------
locals {
  # Validate that only one logging destination is enabled at a time
  enabled_logging_destinations = (
    (var.logging_dist_cloudwatch ? 1 : 0) +
    (var.logging_dist_s3 ? 1 : 0) +
    (var.logging_dist_firehose ? 1 : 0)
  )

  # Get current AWS account ID and region
  current_account_id = data.aws_caller_identity.current.account_id
  current_region     = data.aws_region.current.name

  # Select appropriate WAF ACL ARN based on management type
  waf_acl_arn = !var.wafcharm_managed ? aws_wafv2_web_acl.terraform_managed[0].arn : aws_wafv2_web_acl.wafcharm_managed[0].arn

  # Calculate logging destination ARN based on which option is enabled
  logging_destination_arn = var.logging_dist_cloudwatch ? module.cloudwatch_logging[0].cloudwatch_log_group_arn : (
    var.logging_dist_s3 ? module.s3_logging[0].s3_bucket_arn : (
      var.logging_dist_firehose ? module.firehose_logging[0].firehose_delivery_stream_arn : ""
    )
  )

  # Determine if an S3 bucket needs to be created
  create_s3_bucket = local.validate_logging_destinations && (var.logging_dist_s3 || (var.logging_dist_firehose && var.log_bucket_arn == ""))

  # S3 bucket ARN for Firehose (either from existing ARN or newly created bucket)
  s3_bucket_arn_for_firehose = var.log_bucket_arn != "" ? var.log_bucket_arn : (
    local.create_s3_bucket ? module.s3_logging[0].s3_bucket_arn : ""
  )

  # Validate logging destinations
  validate_logging_destinations = (
    local.enabled_logging_destinations <= 1
    ? true
    : tobool("ERROR: Only one logging destination (CloudWatch, S3, or Firehose) can be enabled at a time")
  )
}

#------------------------------------------------------------------------------
# AWS WAF Web ACL - Terraform Managed
#------------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "terraform_managed" {
  count       = !var.wafcharm_managed ? 1 : 0
  name        = var.name
  description = var.description
  scope       = var.scope

  # Configure default action (allow or block)
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

  # Configure WAF rules
  dynamic "rule" {
    for_each = length(var.rules) > 0 ? var.rules : [{
      name            = "rule-1"
      priority        = 1
      override_action = "count"
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
          rule_action_overrides = [
            {
              name   = "SizeRestrictions_QUERYSTRING"
              action = "count"
            },
            {
              name   = "NoUserAgent_HEADER"
              action = "count"
            }
          ]
          scope_down_statement = {
            geo_match_statement = {
              country_codes = var.default_country_codes
            }
          }
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "rule-metric"
        sampled_requests_enabled   = false
      }
    }]

    content {
      name     = rule.value.name
      priority = rule.value.priority

      # Override action configuration
      dynamic "override_action" {
        for_each = lookup(rule.value, "override_action", null) != null ? [rule.value.override_action] : []
        content {
          count {}
        }
      }

      # Action configuration
      dynamic "action" {
        for_each = lookup(rule.value, "action", null) != null ? [rule.value.action] : []
        content {
          dynamic "allow" {
            for_each = action.value == "allow" ? [1] : []
            content {}
          }
          dynamic "block" {
            for_each = action.value == "block" ? [1] : []
            content {}
          }
          dynamic "count" {
            for_each = action.value == "count" ? [1] : []
            content {}
          }
        }
      }

      # Statement configuration
      statement {
        dynamic "managed_rule_group_statement" {
          for_each = lookup(rule.value.statement, "managed_rule_group_statement", null) != null ? [rule.value.statement.managed_rule_group_statement] : []
          content {
            name        = managed_rule_group_statement.value.name
            vendor_name = managed_rule_group_statement.value.vendor_name

            # Rule action overrides
            dynamic "rule_action_override" {
              for_each = lookup(managed_rule_group_statement.value, "rule_action_overrides", [])
              content {
                name = rule_action_override.value.name
                action_to_use {
                  dynamic "count" {
                    for_each = rule_action_override.value.action == "count" ? [1] : []
                    content {}
                  }
                  dynamic "allow" {
                    for_each = rule_action_override.value.action == "allow" ? [1] : []
                    content {}
                  }
                  dynamic "block" {
                    for_each = rule_action_override.value.action == "block" ? [1] : []
                    content {}
                  }
                }
              }
            }

            # Scope down statement
            dynamic "scope_down_statement" {
              for_each = lookup(managed_rule_group_statement.value, "scope_down_statement", null) != null ? [managed_rule_group_statement.value.scope_down_statement] : []
              content {
                dynamic "geo_match_statement" {
                  for_each = lookup(scope_down_statement.value, "geo_match_statement", null) != null ? [scope_down_statement.value.geo_match_statement] : []
                  content {
                    country_codes = geo_match_statement.value.country_codes
                  }
                }
              }
            }
          }
        }
      }

      # Rule visibility configuration
      visibility_config {
        cloudwatch_metrics_enabled = lookup(rule.value.visibility_config, "cloudwatch_metrics_enabled", var.cloudwatch_metrics_enabled)
        metric_name                = lookup(rule.value.visibility_config, "metric_name", "${rule.value.name}-metric")
        sampled_requests_enabled   = lookup(rule.value.visibility_config, "sampled_requests_enabled", var.sampled_requests_enabled)
      }
    }
  }

  # WAF tags
  tags = var.tags

  # Token domains for CAPTCHA and Challenge
  token_domains = length(var.token_domains) > 0 ? var.token_domains : null

  # Web ACL visibility configuration
  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = var.metric_name
    sampled_requests_enabled   = var.sampled_requests_enabled
  }
}

#------------------------------------------------------------------------------
# AWS WAF Web ACL - WAF Charm Managed
#------------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "wafcharm_managed" {
  count       = var.wafcharm_managed ? 1 : 0
  name        = var.name
  description = var.description
  scope       = var.scope

  # Configure default action (allow or block)
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

  # Ignore changes to rules since they will be managed by WAF Charm
  lifecycle {
    ignore_changes = [rule]
  }

  # Token domains for CAPTCHA and Challenge
  token_domains = length(var.token_domains) > 0 ? var.token_domains : null

  # Web ACL visibility configuration
  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = var.metric_name
    sampled_requests_enabled   = var.sampled_requests_enabled
  }
}

#------------------------------------------------------------------------------
# CloudWatch Logs Module
#------------------------------------------------------------------------------
module "cloudwatch_logging" {
  count  = local.validate_logging_destinations && var.logging_dist_cloudwatch ? 1 : 0
  source = "./modules/logging_dist_cloudwatch"

  # Basic configuration
  name               = var.name
  log_retention_days = var.log_retention_days
  log_class          = var.cloudwatch_log_class

  # Account and region information
  region     = local.current_region
  account_id = local.current_account_id

  # KMS encryption settings
  enable_kms  = var.cloudwatch_enable_kms
  kms_key_arn = var.kms_key_arn
}

#------------------------------------------------------------------------------
# S3 Bucket Module
#------------------------------------------------------------------------------
module "s3_logging" {
  count  = local.create_s3_bucket ? 1 : 0
  source = "./modules/logging_dist_s3"

  # Basic configuration
  name          = var.name
  bucket_prefix = var.s3_bucket_prefix

  # Intelligent tiering settings
  enable_intelligent_tiering = var.enable_intelligent_tiering
  intelligent_tiering_days   = var.intelligent_tiering_days

  # KMS encryption settings
  enable_kms  = var.log_bucket_keys
  kms_key_arn = var.kms_key_arn
}

#------------------------------------------------------------------------------
# Kinesis Firehose Module
#------------------------------------------------------------------------------
module "firehose_logging" {
  count  = local.validate_logging_destinations && var.logging_dist_firehose ? 1 : 0
  source = "./modules/logging_dist_firehose"

  # Basic configuration
  name = var.name

  # S3 bucket configuration
  log_bucket_arn = var.log_bucket_arn
  s3_bucket_arn  = local.s3_bucket_arn_for_firehose

  # Prefix configuration
  log_s3_prefix              = var.log_s3_prefix
  log_s3_error_output_prefix = var.log_s3_error_output_prefix

  # Buffer settings
  firehose_buffer_interval = var.firehose_buffer_interval
  firehose_buffer_size     = var.firehose_buffer_size

  # CloudWatch error logging configuration
  enable_error_logging     = var.firehose_enable_error_logging
  error_log_group_name     = var.firehose_error_log_group_name
  error_log_retention_days = var.firehose_error_log_retention_days

  # S3 prefix timezone settings
  s3_prefix_timezone              = var.log_s3_prefix_timezone
  s3_error_output_prefix_timezone = var.log_s3_error_output_prefix_timezone

  # Firehose processing configuration
  enable_processing = var.firehose_enable_processing
  processors        = var.firehose_processors

  # KMS encryption settings
  enable_kms      = var.log_bucket_keys
  kms_key_arn     = var.kms_key_arn
  log_bucket_keys = var.log_bucket_keys
}

#------------------------------------------------------------------------------
# AWS WAF Web ACL Logging Configuration
#------------------------------------------------------------------------------
resource "aws_wafv2_web_acl_logging_configuration" "logging_conf" {
  count = local.validate_logging_destinations && local.enabled_logging_destinations > 0 ? 1 : 0

  # Use the calculated logging destination ARN
  log_destination_configs = [local.logging_destination_arn]

  # Use the calculated WAF ACL ARN
  resource_arn = local.waf_acl_arn

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
