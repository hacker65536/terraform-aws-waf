provider "aws" {
  region = "ap-northeast-1"
}

# Create a KMS key for encryption
resource "aws_kms_key" "waf_logs" {
  description             = "KMS key for WAF logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "waf_logs" {
  name          = "alias/waf-logs"
  target_key_id = aws_kms_key.waf_logs.key_id
}

# Example with S3 logging and KMS encryption
module "waf_with_kms_encryption" {
  source = "../../"

  name        = "example-waf-kms"
  description = "Example WAF with KMS encryption for logs"
  scope       = "REGIONAL"

  # Enable S3 logging
  logging_dist_s3 = true

  # Enable KMS encryption
  log_bucket_keys = true
  kms_key_arn     = aws_kms_key.waf_logs.arn

  # Optional S3 configurations
  s3_bucket_prefix        = "kms-encrypted-waf-logs-"
  enable_intelligent_tiering = true
  intelligent_tiering_days   = 30
}

module "waf_with_encryption" {
  source = "../../"
  
  name        = "secure-waf"
  description = "WAF with KMS encrypted logs"
  scope       = "REGIONAL"
  
  # Enable S3 logging
  logging_dist_s3 = true
  
  # Enable KMS encryption
  log_bucket_keys = true
  kms_key_arn     = aws_kms_key.waf_logs.arn
}