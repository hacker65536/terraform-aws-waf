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
    sid    = ""
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
