variable "name" {
  type        = string
  description = "(Required) Name of the WebACL"
}

variable "description" {
  type        = string
  description = "(Optional) Description of WebACL"
  default     = null
}

variable "scope" {
  type        = string
  description = "(Required) Specifies whether this is for an AWS CloudFront distribution or for a regional application"
  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.scope)
    error_message = "'scope' must be one of [CLOUDFRONT, REGIONAL]."
  }
}

variable "tags" {
  description = "(Optional) Map of key-value pairs to associate with the resource."
  type        = map(string)
  default     = null
}


variable "wafcharm_managed" {
  type        = bool
  default     = false
  description = "(Optional) If true, the WebACL's rule will be managed by the wafcharm."

}

variable "default_action" {
  description = "(Required) Action to perform if none of the rules contained in the WebACL match."
  type        = string
  default     = "allow"
  validation {
    condition     = var.default_action == "allow" || var.default_action == "block"
    error_message = "ERROR: the value of variable 'default_action' must be one of [allow, block]."
  }
}

variable "sampled_requests_enabled" {
  type        = bool
  default     = true
  description = "(Optional) If true, AWS WAF will allow or block HTTP requests based on what WAF considers to be most likely to indicate a matching rule. If false, AWS WAF will only use the rules that are explicitly configured to decide whether to allow or block an HTTP request."
}

variable "cloudwatch_metrics_enabled" {
  type        = bool
  default     = true
  description = "(Optional) If true, associated CloudWatch metrics will be enabled."
}

variable "rules" {
  type        = any
  description = "(Optional) A list of rules for the WebACL."
  default     = []
}

# WAF Logging Configuration
# 
# This module supports three different types of logging destinations:
# - CloudWatch Logs
# - S3 Bucket
# - Kinesis Firehose
#
# Due to AWS WAF constraints, only one logging destination can be enabled at a time.
# The variables below have validation rules to ensure that this constraint is met.

variable "logging_dist_cloudwatch" {
  type        = bool
  default     = false
  description = "(Optional) If true, all WebACL traffic will be logged to CloudWatch. Only one of logging_dist_cloudwatch, logging_dist_s3, or logging_dist_firehose can be true."
}

variable "logging_dist_s3" {
  type        = bool
  default     = false
  description = "(Optional) If true, all WebACL traffic will be logged to S3. Only one of logging_dist_cloudwatch, logging_dist_s3, or logging_dist_firehose can be true."
}

variable "logging_dist_firehose" {
  type        = bool
  default     = false
  description = "(Optional) If true, all WebACL traffic will be logged to Kinesis Firehose. Only one of logging_dist_cloudwatch, logging_dist_s3, or logging_dist_firehose can be true."
}

variable "log_bucket_arn" {
  type        = string
  description = "ARN of an existing S3 bucket to use for logs"
  default     = ""
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
  description = "S3 prefix for WAF logs. A trailing slash (/) is required."
  default     = "waf-fulllog/"
  validation {
    condition     = can(regex("\\/$", var.log_s3_prefix))
    error_message = "ERROR: the value of variable 'log_prefix' must have a trailing slash(/)."
  }
}

variable "log_s3_error_output_prefix" {
  type        = string
  description = "S3 prefix for WAF error logs. A trailing slash (/) is required."
  default     = "waf-fulllog-error/"
  validation {
    condition     = can(regex("\\/$", var.log_s3_error_output_prefix))
    error_message = "ERROR: the value of variable 'log_error_output_prefix' must have a trailing slash(/)."
  }
}

variable "log_s3_prefix_timezone" {
  type        = string
  description = "(Optional) Timezone for S3 prefix date formatting in Firehose. This sets the custom_time_zone parameter for Firehose delivery, affecting how date patterns in S3 prefixes are evaluated. Valid values include timezones like 'UTC', 'America/New_York', 'Asia/Tokyo', 'Europe/London', etc. See the IANA Time Zone Database for valid values."
  default     = "UTC"
}

variable "log_s3_error_output_prefix_timezone" {
  type        = string
  description = "(Optional) Timezone for S3 error output prefix date formatting in Firehose. This sets the custom_time_zone parameter for error output paths. Valid values include timezones like 'UTC', 'America/New_York', 'Asia/Tokyo', 'Europe/London', etc. See the IANA Time Zone Database for valid values."
  default     = "UTC"
}

variable "log_bucket_keys" {
  type        = bool
  default     = false
  description = "(Optional) If true, enables KMS encryption for logs stored in S3 and Firehose. When enabled, logs are encrypted using either the specified KMS key or an AWS managed key."
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "(Optional) ARN of KMS key to use for encrypting logs in S3, Firehose, and CloudWatch. If not specified but log_bucket_keys is true, an AWS managed key will be used."
}

variable "cloudwatch_enable_kms" {
  type        = bool
  default     = false
  description = "(Optional) If true, enables KMS encryption for CloudWatch logs. This is separate from S3/Firehose encryption."
}


variable "log_retention_days" {
  type        = number
  default     = 90
  description = "(Optional) Number of days to retain WAF logs in CloudWatch."
}

variable "cloudwatch_log_class" {
  type        = string
  description = "(Optional) Log Class for CloudWatch Log Group. Valid values: STANDARD, INFREQUENT_ACCESS"
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "INFREQUENT_ACCESS"], var.cloudwatch_log_class)
    error_message = "Log class must be either STANDARD or INFREQUENT_ACCESS."
  }
}

variable "redact_authorization_header" {
  type        = bool
  default     = false
  description = "(Optional) Whether to redact the 'authorization' header in the logs."
}

variable "enable_logging_filter" {
  type        = bool
  default     = false
  description = "(Optional) Whether to enable logging filters to selectively log requests."
}

variable "enable_intelligent_tiering" {
  type        = bool
  description = "(Optional) Enable Intelligent-Tiering storage class for logs in S3"
  default     = true
}

variable "intelligent_tiering_days" {
  type        = number
  description = "(Optional) Number of days after which logs will be moved to Intelligent-Tiering storage class"
  default     = 30
}

variable "token_domains" {
  type        = list(string)
  description = "(Optional) Domain names that you want to associate with the web ACL for automatic token handling."
  default     = []
}

variable "metric_name" {
  type        = string
  description = "(Required) A friendly name of the CloudWatch metric for the WebACL."
  default     = "waf-web-acl-metric"
}

variable "default_country_codes" {
  type        = list(string)
  description = "(Optional) Default list of country codes to use in geo match statements when not specified in rules"
  default     = ["US", "NL"]
}

variable "s3_bucket_prefix" {
  type        = string
  description = "(Optional) Prefix for the S3 bucket name used for logs"
  default     = "aws-waf-logs-"
}

variable "firehose_enable_error_logging" {
  type        = bool
  default     = true
  description = "(Optional) Enable CloudWatch Logs for error logging of the Firehose delivery stream"
}

variable "firehose_error_log_group_name" {
  type        = string
  default     = ""
  description = "(Optional) CloudWatch Log group name for Firehose error logs. If empty, a default name will be used."
}

variable "firehose_error_log_retention_days" {
  type        = number
  default     = 14
  description = "(Optional) Number of days to retain Firehose error logs in CloudWatch"
}

variable "firehose_enable_processing" {
  type        = bool
  default     = false
  description = "(Optional) Enable processing configuration for Firehose delivery stream"
}

variable "firehose_processors" {
  type = list(object({
    type = string
    parameters = list(object({
      parameter_name  = string
      parameter_value = string
    }))
  }))
  description = "(Optional) List of processors for Firehose delivery stream. Each processor has a type and list of parameters."
  default     = []
  /*
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
  */
}

