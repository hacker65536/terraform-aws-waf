resource "aws_s3_bucket" "log_bucket" {
  bucket_prefix = "${var.bucket_prefix}${var.name}-"

  lifecycle {
    prevent_destroy = true
  }
}

# Add Intelligent-Tiering lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  count  = var.enable_intelligent_tiering ? 1 : 0
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "intelligent-tiering"
    status = "Enabled"

    # Transition to Intelligent-Tiering after the configured number of days
    transition {
      days          = var.intelligent_tiering_days
      storage_class = "INTELLIGENT_TIERING"
    }

    # Apply to all objects
    filter {
      prefix = ""
    }
  }
}

# Add server-side encryption configuration for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  count  = var.enable_kms ? 1 : 0
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != "" ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null
    }
    bucket_key_enabled = var.kms_key_arn != "" ? true : false
  }
}
