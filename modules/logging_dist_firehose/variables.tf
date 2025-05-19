variable "name" {
  type        = string
  description = "Name of the WAF Web ACL (used for Firehose naming)"
}

variable "log_bucket_arn" {
  type        = string
  description = "ARN of an existing S3 bucket to use for logs"
  default     = ""
}

variable "log_bucket_keys" {
  type        = bool
  default     = false
  description = "Enable KMS key access to S3 bucket for log encryption"
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "ARN of KMS key to use for encrypting logs"
}

variable "firehose_buffer_interval" {
  type        = number
  description = "Buffer interval for Firehose in seconds (60-900)"
  default     = 300
  validation {
    condition     = 60 <= var.firehose_buffer_interval && var.firehose_buffer_interval <= 900
    error_message = "ERROR: buffer_interval must be between 60 and 900."
  }
}

variable "firehose_buffer_size" {
  type        = number
  description = "Buffer size for Firehose in MB (1-128)"
  default     = 128
  validation {
    condition     = 1 <= var.firehose_buffer_size && var.firehose_buffer_size <= 128
    error_message = "ERROR: buffer_size must be between 1 and 128."
  }
}

variable "log_s3_prefix" {
  type        = string
  description = "S3 prefix for WAF logs"
  default     = "waf-fulllog/"
  validation {
    condition     = can(regex("\\/$", var.log_s3_prefix))
    error_message = "ERROR: the value of variable 'log_prefix' must have a trailing slash(/)."
  }
}

variable "log_s3_error_output_prefix" {
  type        = string
  description = "S3 prefix for WAF error logs"
  default     = "waf-fulllog-error/"
  validation {
    condition     = can(regex("\\/$", var.log_s3_error_output_prefix))
    error_message = "ERROR: the value of variable 'log_error_output_prefix' must have a trailing slash(/)."
  }
}

# This is used in the main module file to create the S3 bucket if needed
variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket created in the S3 module"
  default     = ""
}
