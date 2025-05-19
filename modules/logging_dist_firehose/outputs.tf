output "firehose_delivery_stream_id" {
  description = "The ID of the Kinesis Firehose delivery stream used for WAF logs."
  value       = aws_kinesis_firehose_delivery_stream.firehose.id
}

output "firehose_delivery_stream_arn" {
  description = "The ARN of the Kinesis Firehose delivery stream used for WAF logs."
  value       = aws_kinesis_firehose_delivery_stream.firehose.arn
}
