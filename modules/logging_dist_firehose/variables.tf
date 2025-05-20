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

variable "enable_error_logging" {
  type        = bool
  default     = true
  description = "Enable CloudWatch Logs for error logging of the Firehose delivery stream"
}

variable "error_log_group_name" {
  type        = string
  default     = ""
  description = "CloudWatch Log group name for Firehose error logs. If empty, 'aws-waf-logs-error-{var.name}' will be used."
}

variable "error_log_retention_days" {
  type        = number
  default     = 14
  description = "Number of days to retain Firehose error logs in CloudWatch"
}

variable "s3_prefix_timezone" {
  type        = string
  description = "Timezone for S3 prefix date formatting. Sets the custom_time_zone parameter for Firehose's extended_s3_configuration. Valid timezone values follow the IANA Time Zone Database format (e.g., 'UTC', 'America/New_York', 'Asia/Tokyo', 'Europe/London', etc.). This affects how date patterns in the S3 prefix are interpreted."
  default     = "UTC"
}

variable "s3_error_output_prefix_timezone" {
  type        = string
  description = "Timezone for S3 error output prefix date formatting. Sets the custom_time_zone parameter for error output prefix formatting. Valid timezone values follow the IANA Time Zone Database format (e.g., 'UTC', 'America/New_York', 'Asia/Tokyo', 'Europe/London', etc.). This affects how date patterns in the error output S3 prefix are interpreted."
  default     = "UTC"
}

variable "enable_processing" {
  type        = bool
  description = "Enable processing configuration for Firehose delivery stream"
  default     = true
}

variable "processors" {
  type = list(object({
    type = string
    parameters = list(object({
      parameter_name  = string
      parameter_value = string
    }))
  }))
  description = "List of processors for Firehose delivery stream. Each processor has a type and list of parameters. Default is a simple AppendDelimiterToRecord processor."
  default = [
    {
      type = "AppendDelimiterToRecord"
      parameters = [
        {
          parameter_name  = "Delimiter"
          parameter_value = "\\n"
        }
      ]
    }
  ]
}

# This is used in the main module file to create the S3 bucket if needed
variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket created in the S3 module"
  default     = ""
}
