output "web_acl_id" {
  description = "The ID of the WAF WebACL."
  value       = var.wafcharm_managed == false ? aws_wafv2_web_acl.terraform_managed[0].id : aws_wafv2_web_acl.wafcharm_managed[0].id
}

output "web_acl_arn" {
  description = "The ARN of the WAF WebACL."
  value       = var.wafcharm_managed == false ? aws_wafv2_web_acl.terraform_managed[0].arn : aws_wafv2_web_acl.wafcharm_managed[0].arn
}

output "web_acl_capacity" {
  description = "The capacity of the WAF WebACL."
  value       = var.wafcharm_managed == false ? aws_wafv2_web_acl.terraform_managed[0].capacity : aws_wafv2_web_acl.wafcharm_managed[0].capacity
}

output "log_bucket_id" {
  description = "The ID of the S3 bucket used for WAF logs."
  value       = var.logging_dist_s3 == true || (var.logging_dist_firehose == true && var.log_bucket_arn == "") ? module.s3_logging[0].s3_bucket_id : null
}

output "log_bucket_arn" {
  description = "The ARN of the S3 bucket used for WAF logs."
  value       = var.logging_dist_s3 == true || (var.logging_dist_firehose == true && var.log_bucket_arn == "") ? module.s3_logging[0].s3_bucket_arn : null
}

output "firehose_delivery_stream_id" {
  description = "The ID of the Kinesis Firehose delivery stream used for WAF logs."
  value       = var.logging_dist_firehose == true ? module.firehose_logging[0].firehose_delivery_stream_id : null
}

output "firehose_delivery_stream_arn" {
  description = "The ARN of the Kinesis Firehose delivery stream used for WAF logs."
  value       = var.logging_dist_firehose == true ? module.firehose_logging[0].firehose_delivery_stream_arn : null
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group used for WAF logs."
  value       = var.logging_dist_cloudwatch == true ? module.cloudwatch_logging[0].cloudwatch_log_group_name : null
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group used for WAF logs."
  value       = var.logging_dist_cloudwatch == true ? module.cloudwatch_logging[0].cloudwatch_log_group_arn : null
}
