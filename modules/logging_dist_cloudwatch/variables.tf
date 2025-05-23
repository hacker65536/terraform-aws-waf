variable "name" {
  type        = string
  description = "Name of the WAF Web ACL (used for naming log group)"
}

variable "log_retention_days" {
  type        = number
  default     = 90
  description = "Number of days to retain WAF logs in CloudWatch"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "log_class" {
  type        = string
  description = "Log Class for CloudWatch Log Group. Valid values: STANDARD, INFREQUENT_ACCESS"
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "INFREQUENT_ACCESS"], var.log_class)
    error_message = "Log class must be either STANDARD or INFREQUENT_ACCESS."
  }
}

variable "enable_kms" {
  type        = bool
  default     = false
  description = "Whether to enable KMS encryption for the CloudWatch log group"
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "ARN of KMS key to use for encrypting the CloudWatch log group. If not specified but enable_kms is true, the AWS managed key will be used."
}
