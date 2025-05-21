#--------------------------------------------------------------
# Firehose Delivery Stream Module for WAF Logs
#--------------------------------------------------------------

locals {
  # Determine the destination S3 bucket ARN
  destination_bucket_arn = var.log_bucket_arn != "" ? var.log_bucket_arn : var.s3_bucket_arn

  # Define bucket resources for IAM permissions
  bucket_resources = [
    local.destination_bucket_arn,
    "${local.destination_bucket_arn}/*"
  ]

  # Default log group name if not specified
  log_group_name = var.error_log_group_name != "" ? var.error_log_group_name : "aws-waf-logs-error-${var.name}"
}

resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  name        = "aws-waf-logs-${var.name}"
  destination = "extended_s3"

  # Add server-side encryption configuration
  dynamic "server_side_encryption" {
    for_each = var.enable_kms ? [1] : []
    content {
      enabled  = true
      key_type = var.kms_key_arn != "" ? "CUSTOMER_MANAGED_CMK" : "AWS_OWNED_CMK"
      key_arn  = var.kms_key_arn != "" ? var.kms_key_arn : null
    }
  }

  extended_s3_configuration {
    # Base configuration
    role_arn           = aws_iam_role.firehose.arn
    bucket_arn         = local.destination_bucket_arn
    compression_format = "GZIP"
    s3_backup_mode     = "Disabled"

    # Buffer settings
    buffering_interval = var.firehose_buffer_interval
    buffering_size     = var.firehose_buffer_size

    # S3 path configuration with timezone support
    prefix              = var.log_s3_prefix
    error_output_prefix = var.log_s3_error_output_prefix
    custom_time_zone    = var.s3_prefix_timezone

    # Add KMS key for S3 delivery if enabled
    kms_key_arn = var.enable_kms && var.kms_key_arn != "" ? var.kms_key_arn : null

    # Configurable processing configuration
    dynamic "processing_configuration" {
      for_each = var.enable_processing ? [1] : []
      content {
        enabled = true

        # Dynamic processors from variables
        dynamic "processors" {
          for_each = var.processors
          content {
            type = processors.value.type

            dynamic "parameters" {
              for_each = processors.value.parameters
              content {
                parameter_name  = parameters.value.parameter_name
                parameter_value = parameters.value.parameter_value
              }
            }
          }
        }
      }
    }

    # CloudWatch Logs configuration for error logging
    dynamic "cloudwatch_logging_options" {
      for_each = var.enable_error_logging ? [1] : []
      content {
        enabled         = true
        log_group_name  = aws_cloudwatch_log_group.firehose_error_logs[0].name
        log_stream_name = aws_cloudwatch_log_stream.firehose_error_logs[0].name
      }
    }
  }
}

#--------------------------------------------------------------
# IAM Role and Policies
#--------------------------------------------------------------
resource "aws_iam_role" "firehose" {
  name               = "KinesisFirehoseServiceRole-${var.name}-aws-logs"
  path               = "/service-role/"
  description        = "Role for Kinesis Firehose to deliver WAF logs"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role_policy.json
}

resource "aws_iam_role_policy" "firehose" {
  name   = "firehose-delivery-policy"
  role   = aws_iam_role.firehose.id
  policy = data.aws_iam_policy_document.firehose.json
}

# Trust policy for Firehose service
data "aws_iam_policy_document" "firehose_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

# Permission policy for Firehose
data "aws_iam_policy_document" "firehose" {
  # S3 write permissions
  statement {
    sid    = "S3Access"
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = local.bucket_resources
  }

  # Add CloudWatch Logs permissions when error logging is enabled
  # CloudWatch Logs permissions when error logging is enabled
  dynamic "statement" {
    for_each = var.enable_error_logging ? [1] : []
    content {
      sid    = "CloudWatchLogsAccess"
      effect = "Allow"

      actions = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]

      resources = [
        aws_cloudwatch_log_group.firehose_error_logs[0].arn,
        "${aws_cloudwatch_log_group.firehose_error_logs[0].arn}:log-stream:*"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.log_bucket_keys && var.kms_key_arn != "" ? [var.kms_key_arn] : []

    content {
      sid    = "AllowKMSAccess"
      effect = "Allow"

      actions = [
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Encrypt",
        "kms:DescribeKey",
        "kms:Decrypt",
      ]

      resources = [
        statement.value
      ]
    }
  }
}

# CloudWatch Log group for Firehose error logs
resource "aws_cloudwatch_log_group" "firehose_error_logs" {
  count             = var.enable_error_logging ? 1 : 0
  name              = local.log_group_name
  retention_in_days = var.error_log_retention_days
}

# CloudWatch Log stream for Firehose error logs
resource "aws_cloudwatch_log_stream" "firehose_error_logs" {
  count          = var.enable_error_logging ? 1 : 0
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose_error_logs[0].name
}
