output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group used for WAF logs."
  value       = aws_cloudwatch_log_group.log_group.arn
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group used for WAF logs."
  value       = aws_cloudwatch_log_group.log_group.name
}

output "cloudwatch_log_group_class" {
  description = "The storage class of the CloudWatch log group used for WAF logs."
  value       = aws_cloudwatch_log_group.log_group.log_group_class
}
