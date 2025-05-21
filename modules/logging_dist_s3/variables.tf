variable "name" {
  type        = string
  description = "Name of the WAF Web ACL (used for bucket naming)"
}

variable "enable_intelligent_tiering" {
  type        = bool
  description = "Enable Intelligent-Tiering storage class for logs"
  default     = true
}

variable "intelligent_tiering_days" {
  type        = number
  description = "Number of days after which logs will be moved to Intelligent-Tiering storage class"
  default     = 30
}

variable "bucket_prefix" {
  type        = string
  description = "Prefix for the S3 bucket name"
  default     = "aws-waf-logs-"
}

variable "enable_kms" {
  type        = bool
  default     = false
  description = "Whether to enable KMS encryption for the S3 bucket"
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "ARN of KMS key to use for encrypting the S3 bucket. If not specified but enable_kms is true, the AWS managed key will be used."
}
