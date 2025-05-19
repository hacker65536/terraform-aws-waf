# Example of using the AWS WAF module with different logging options

provider "aws" {
  region = "ap-northeast-1"
}

module "waf_with_all_logging" {
  source = "../../" # Adjust path as needed

  name        = "example-waf-all-logging"
  description = "Example WAF with all logging options enabled"
  scope       = "REGIONAL"

  # Enable all logging options
  logging_dist_cloudwatch = true
  logging_dist_s3         = true
  logging_dist_firehose   = true

  # Optional configurations
  log_retention_days          = 30
  cloudwatch_log_class        = "STANDARD"
  redact_authorization_header = true
  enable_logging_filter       = true

  # Firehose specific settings
  firehose_buffer_interval   = 60
  firehose_buffer_size       = 5
  log_s3_prefix              = "waf-logs/"
  log_s3_error_output_prefix = "waf-errors/"
}

module "waf_with_cloudwatch_only" {
  source = "../../" # Adjust path as needed

  name        = "example-waf-cloudwatch-only"
  description = "Example WAF with CloudWatch logging only"
  scope       = "REGIONAL"

  # Enable only CloudWatch logging
  logging_dist_cloudwatch = true
  logging_dist_s3         = false
  logging_dist_firehose   = false

  # CloudWatch specific settings
  log_retention_days   = 14
  cloudwatch_log_class = "INFREQUENT_ACCESS" # Suitable for logs with infrequent access patterns
}

module "waf_with_s3_only" {
  source = "../../" # Adjust path as needed

  name        = "example-waf-s3-only"
  description = "Example WAF with S3 logging only"
  scope       = "REGIONAL"

  # Enable only S3 logging
  logging_dist_cloudwatch = false
  logging_dist_s3         = true
  logging_dist_firehose   = false
}

module "waf_with_firehose_only" {
  source = "../../" # Adjust path as needed

  name        = "example-waf-firehose-only"
  description = "Example WAF with Firehose logging only"
  scope       = "REGIONAL"

  # Enable only Firehose logging
  logging_dist_cloudwatch = false
  logging_dist_s3         = false
  logging_dist_firehose   = true

  # You can specify an existing S3 bucket ARN for Firehose to use
  # log_bucket_arn = "arn:aws:s3:::existing-bucket-name"
}

output "waf_with_all_logging_id" {
  value = module.waf_with_all_logging.web_acl_id
}

output "waf_with_all_logging_s3_bucket" {
  value = module.waf_with_all_logging.log_bucket_id
}

output "waf_with_all_logging_cloudwatch_log_group" {
  value = module.waf_with_all_logging.cloudwatch_log_group_name
}

output "waf_with_all_logging_firehose_stream" {
  value = module.waf_with_all_logging.firehose_delivery_stream_id
}
