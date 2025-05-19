output "s3_bucket_id" {
  description = "The ID of the S3 bucket used for WAF logs."
  value       = aws_s3_bucket.log_bucket.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for WAF logs."
  value       = aws_s3_bucket.log_bucket.arn
}
