resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  name        = "aws-waf-logs-${var.name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose.arn
    bucket_arn          = var.log_bucket_arn != "" ? var.log_bucket_arn : var.s3_bucket_arn
    buffering_interval  = var.firehose_buffer_interval
    buffering_size      = var.firehose_buffer_size
    compression_format  = "GZIP"
    prefix              = var.log_s3_prefix
    error_output_prefix = var.log_s3_error_output_prefix

    # Custom timezone configuration - directly configuring the timezone
    custom_time_zone = var.s3_prefix_timezone
    s3_backup_mode   = "Disabled"

    # Configurable processing configuration for record transformation
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

data "aws_iam_policy_document" "firehose_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "firehose" {
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

    resources = [
      var.log_bucket_arn != "" ? var.log_bucket_arn : var.s3_bucket_arn,
      var.log_bucket_arn != "" ? "${var.log_bucket_arn}/*" : "${var.s3_bucket_arn}/*"
    ]
  }

  # Add CloudWatch Logs permissions when error logging is enabled
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
  name              = var.error_log_group_name != "" ? var.error_log_group_name : "aws-waf-logs-error-${var.name}"
  retention_in_days = var.error_log_retention_days
}

# CloudWatch Log stream for Firehose error logs
resource "aws_cloudwatch_log_stream" "firehose_error_logs" {
  count          = var.enable_error_logging ? 1 : 0
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose_error_logs[0].name
}
