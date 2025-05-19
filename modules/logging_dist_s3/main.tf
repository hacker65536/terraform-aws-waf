resource "aws_s3_bucket" "log_bucket" {
  bucket_prefix = "aws-waf-logs-${var.name}-"

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
