output "firehose_delivery_stream_id" {
  description = "The ID of the Kinesis Firehose delivery stream used for WAF logs."
  value       = aws_kinesis_firehose_delivery_stream.firehose.id
}

output "firehose_delivery_stream_arn" {
  description = "The ARN of the Kinesis Firehose delivery stream used for WAF logs."
  value       = aws_kinesis_firehose_delivery_stream.firehose.arn
}

output "error_log_group_name" {
  description = "The name of the CloudWatch Log group used for Firehose error logs."
  value       = var.enable_error_logging ? aws_cloudwatch_log_group.firehose_error_logs[0].name : null
}

output "error_log_group_arn" {
  description = "The ARN of the CloudWatch Log group used for Firehose error logs."
  value       = var.enable_error_logging ? aws_cloudwatch_log_group.firehose_error_logs[0].arn : null
}
