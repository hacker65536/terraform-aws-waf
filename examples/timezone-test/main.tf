provider "aws" {
  region = "ap-northeast-1"
}

module "waf_with_timezone" {
  source = "../../"

  name        = "timezone-test-waf"
  description = "WAF with timezone configuration for S3 prefixes"
  scope       = "REGIONAL"

  # Enable Firehose logging only
  logging_dist_cloudwatch = false
  logging_dist_s3         = false
  logging_dist_firehose   = true

  # Firehose buffer settings
  firehose_buffer_interval = 60
  firehose_buffer_size     = 5

  # S3 prefix with date pattern using Tokyo timezone
  log_s3_prefix          = "waf-logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
  log_s3_prefix_timezone = "Asia/Tokyo"

  # Error output prefix with date pattern using Tokyo timezone
  log_s3_error_output_prefix          = "waf-errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  log_s3_error_output_prefix_timezone = "Asia/Tokyo"

  # Enable error logging to CloudWatch
  firehose_enable_error_logging     = true
  firehose_error_log_retention_days = 7
  firehose_error_log_group_name     = "firehose-timezone-test-errors"

  # Advanced Firehose processing configuration
  firehose_enable_processing = true
  firehose_processors = [
    {
      # Extract WAF metadata for better organization and searchability
      type = "MetadataExtraction"
      parameters = [
        {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        },
        {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{timestamp:.timestamp, action:.action, ruleId:.ruleId, requestId:.requestId, terminatingRuleId:.terminatingRuleId}"
        }
      ]
    },
    {
      # Optionally add Lambda transformation
      # Note: Requires Lambda ARN to be configured correctly
      type = "Lambda"
      parameters = [
        {
          parameter_name  = "LambdaArn"
          parameter_value = "arn:aws:lambda:ap-northeast-1:123456789012:function:waf-log-enricher"
        },
        {
          parameter_name  = "NumberOfRetries"
          parameter_value = "3"
        },
        {
          parameter_name  = "RoleArn"
          parameter_value = "arn:aws:iam::123456789012:role/firehose-lambda-role"
        },
        {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = "3"
        },
        {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = "60"
        }
      ]
    },
    {
      # Append new line at the end of each record (always keep this as the last processor)
      type = "AppendDelimiterToRecord"
      parameters = [
        {
          parameter_name  = "Delimiter"
          parameter_value = "\\n"
        }
      ]
    }
  ]
}

output "firehose_delivery_stream_id" {
  value = module.waf_with_timezone.firehose_delivery_stream_id
}

output "log_bucket_id" {
  value = module.waf_with_timezone.log_bucket_id
}
