# AWS WAF Module with Multiple Logging Options

This Terraform module manages AWS WAF (Web Application Firewall) resources with flexible logging options.

## Features

- Support for both Terraform-managed and WAF Charm-managed WAFs
- Three flexible logging destination options (one can be enabled at a time):
  - CloudWatch Logs
  - S3 Bucket
  - Kinesis Firehose
- Configurable logging settings including retention periods and buffering options
- Support for log field redaction and filtering
- Modular structure with dedicated submodules for each logging type

## Module Structure

This module has a modular structure with separate submodules for each logging type:

- `logging_dist_cloudwatch`: Handles CloudWatch logging configuration
- `logging_dist_s3`: Handles S3 bucket logging configuration
- `logging_dist_firehose`: Handles Firehose delivery stream configuration

The main module orchestrates these submodules based on the selected logging destination. Due to AWS WAF constraints, only one logging destination can be enabled at a time.

## Documentation Generation

This module uses [terraform-docs](https://github.com/terraform-docs/terraform-docs) to generate documentation. 

Install terraform-docs:
```bash
# macOS
brew install terraform-docs

# Linux
curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
mv terraform-docs /usr/local/bin/
```

Generate documentation:
```bash
# Generate markdown for the main module
terraform-docs markdown table --output-file README.md --output-mode inject .

# Generate markdown for submodules
terraform-docs markdown table --output-file README.md --output-mode inject ./modules/logging_dist_cloudwatch
terraform-docs markdown table --output-file README.md --output-mode inject ./modules/logging_dist_s3
terraform-docs markdown table --output-file README.md --output-mode inject ./modules/logging_dist_firehose
```

## Code Quality Features

This module implements several best practices for Terraform code quality:

1. **Version Constraints**: Proper version constraints for Terraform and AWS provider
2. **Simplified Boolean Expressions**: Direct boolean values instead of comparison operators where appropriate
3. **Dynamic Resource Creation**: Uses Terraform's dynamic blocks for flexible rule configuration
4. **Improved Naming**: Consistent and descriptive variable and resource naming
5. **Parameterization**: Avoids hardcoded values with configurable variables
6. **Intelligent Storage**: S3 bucket with optional Intelligent-Tiering for cost optimization
7. **Comprehensive Documentation**: Clear descriptions for all variables and resources
8. **Code Modularity**: Separated logging functionality into dedicated submodules

## Usage

### Basic Usage with Single Logging Destination

```hcl
module "waf" {
  source = "path/to/module"
  
  name        = "example-waf"
  description = "Example WAF with CloudWatch logging enabled"
  scope       = "REGIONAL"  # or "CLOUDFRONT"
  
  # Enable logging to only one destination (CloudWatch, S3, or Firehose)
  # Only one of these can be set to true
  logging_dist_cloudwatch = true
  logging_dist_s3         = false
  logging_dist_firehose   = false
  
  # Optional configurations
  log_retention_days = 30  # CloudWatch log retention
  
  # Firehose specific settings
  firehose_buffer_interval = 60  # seconds
  firehose_buffer_size     = 5   # MB
  log_s3_prefix            = "waf-logs/"
  log_s3_error_output_prefix = "waf-errors/"
}
```

### CloudWatch Logs Only

```hcl
module "waf_cloudwatch" {
  source = "path/to/module"
  
  name        = "example-waf"
  description = "Example WAF with CloudWatch logging only"
  scope       = "REGIONAL"
  
  # Enable only CloudWatch logging
  logging_dist_cloudwatch = true
  logging_dist_s3         = false
  logging_dist_firehose   = false
  
  # CloudWatch specific settings
  log_retention_days = 14
  cloudwatch_log_class = "INFREQUENT_ACCESS"  # Suitable for logs with infrequent access patterns
}
```

### S3 Bucket Only

```hcl
module "waf_s3" {
  source = "path/to/module"
  
  name        = "example-waf"
  description = "Example WAF with S3 logging only"
  scope       = "REGIONAL"
  
  # Enable only S3 logging
  logging_dist_cloudwatch = false
  logging_dist_s3         = true
  logging_dist_firehose   = false
}
```

### Kinesis Firehose Only

```hcl
module "waf_firehose" {
  source = "path/to/module"
  
  name        = "example-waf"
  description = "Example WAF with Firehose logging only"
  scope       = "REGIONAL"
  
  # Enable only Firehose logging
  logging_dist_cloudwatch = false
  logging_dist_s3         = false
  logging_dist_firehose   = true
  
  # You can specify an existing S3 bucket for Firehose
  log_bucket_arn = "arn:aws:s3:::existing-bucket-name"
}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.98.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_logging"></a> [cloudwatch\_logging](#module\_cloudwatch\_logging) | ./modules/logging_dist_cloudwatch | n/a |
| <a name="module_firehose_logging"></a> [firehose\_logging](#module\_firehose\_logging) | ./modules/logging_dist_firehose | n/a |
| <a name="module_s3_logging"></a> [s3\_logging](#module\_s3\_logging) | ./modules/logging_dist_s3 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_web_acl.terraform_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl.wafcharm_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_logging_configuration.logging_conf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_class"></a> [cloudwatch\_log\_class](#input\_cloudwatch\_log\_class) | (Optional) Log Class for CloudWatch Log Group. Valid values: STANDARD, INFREQUENT\_ACCESS | `string` | `"STANDARD"` | no |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | (Optional) If true, associated CloudWatch metrics will be enabled. | `bool` | `true` | no |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | (Required) Action to perform if none of the rules contained in the WebACL match. | `string` | `"allow"` | no |
| <a name="input_default_country_codes"></a> [default\_country\_codes](#input\_default\_country\_codes) | (Optional) Default list of country codes to use in geo match statements when not specified in rules | `list(string)` | <pre>[<br/>  "US",<br/>  "NL"<br/>]</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Description of WebACL | `string` | `null` | no |
| <a name="input_enable_intelligent_tiering"></a> [enable\_intelligent\_tiering](#input\_enable\_intelligent\_tiering) | (Optional) Enable Intelligent-Tiering storage class for logs in S3 | `bool` | `true` | no |
| <a name="input_enable_logging_filter"></a> [enable\_logging\_filter](#input\_enable\_logging\_filter) | (Optional) Whether to enable logging filters to selectively log requests. | `bool` | `false` | no |
| <a name="input_firehose_buffer_interval"></a> [firehose\_buffer\_interval](#input\_firehose\_buffer\_interval) | Buffer interval for Firehose in seconds (60-900) | `number` | `300` | no |
| <a name="input_firehose_buffer_size"></a> [firehose\_buffer\_size](#input\_firehose\_buffer\_size) | Buffer size for Firehose in MB (1-128) | `number` | `128` | no |
| <a name="input_intelligent_tiering_days"></a> [intelligent\_tiering\_days](#input\_intelligent\_tiering\_days) | (Optional) Number of days after which logs will be moved to Intelligent-Tiering storage class | `number` | `30` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | (Optional) ARN of KMS key to use for encrypting logs. | `string` | `""` | no |
| <a name="input_log_bucket_arn"></a> [log\_bucket\_arn](#input\_log\_bucket\_arn) | ARN of an existing S3 bucket to use for logs | `string` | `""` | no |
| <a name="input_log_bucket_keys"></a> [log\_bucket\_keys](#input\_log\_bucket\_keys) | (Optional) If true, enables KMS key access to S3 bucket for log encryption. | `bool` | `false` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | (Optional) Number of days to retain WAF logs in CloudWatch. | `number` | `90` | no |
| <a name="input_log_s3_error_output_prefix"></a> [log\_s3\_error\_output\_prefix](#input\_log\_s3\_error\_output\_prefix) | S3 prefix for WAF error logs. A trailing slash (/) is required. | `string` | `"waf-fulllog-error/"` | no |
| <a name="input_log_s3_prefix"></a> [log\_s3\_prefix](#input\_log\_s3\_prefix) | S3 prefix for WAF logs. A trailing slash (/) is required. | `string` | `"waf-fulllog/"` | no |
| <a name="input_logging_dist_cloudwatch"></a> [logging\_dist\_cloudwatch](#input\_logging\_dist\_cloudwatch) | (Optional) If true, all WebACL traffic will be logged to CloudWatch. | `bool` | `false` | no |
| <a name="input_logging_dist_firehose"></a> [logging\_dist\_firehose](#input\_logging\_dist\_firehose) | (Optional) If true, all WebACL traffic will be logged to Kinesis Firehose. | `bool` | `false` | no |
| <a name="input_logging_dist_s3"></a> [logging\_dist\_s3](#input\_logging\_dist\_s3) | (Optional) If true, all WebACL traffic will be logged to S3. | `bool` | `false` | no |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | (Required) A friendly name of the CloudWatch metric for the WebACL. | `string` | `"waf-web-acl-metric"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the WebACL | `string` | n/a | yes |
| <a name="input_redact_authorization_header"></a> [redact\_authorization\_header](#input\_redact\_authorization\_header) | (Optional) Whether to redact the 'authorization' header in the logs. | `bool` | `false` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | (Optional) A list of rules for the WebACL. | `any` | `[]` | no |
| <a name="input_s3_bucket_prefix"></a> [s3\_bucket\_prefix](#input\_s3\_bucket\_prefix) | (Optional) Prefix for the S3 bucket name used for logs | `string` | `"aws-waf-logs-"` | no |
| <a name="input_sampled_requests_enabled"></a> [sampled\_requests\_enabled](#input\_sampled\_requests\_enabled) | (Optional) If true, AWS WAF will allow or block HTTP requests based on what WAF considers to be most likely to indicate a matching rule. If false, AWS WAF will only use the rules that are explicitly configured to decide whether to allow or block an HTTP request. | `bool` | `true` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | (Required) Specifies whether this is for an AWS CloudFront distribution or for a regional application | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of key-value pairs to associate with the resource. | `map(string)` | `null` | no |
| <a name="input_token_domains"></a> [token\_domains](#input\_token\_domains) | (Optional) Domain names that you want to associate with the web ACL for automatic token handling. | `list(string)` | `[]` | no |
| <a name="input_wafcharm_managed"></a> [wafcharm\_managed](#input\_wafcharm\_managed) | (Optional) If true, the WebACL's rule will be managed by the wafcharm. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch log group used for WAF logs. |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | The name of the CloudWatch log group used for WAF logs. |
| <a name="output_firehose_delivery_stream_arn"></a> [firehose\_delivery\_stream\_arn](#output\_firehose\_delivery\_stream\_arn) | The ARN of the Kinesis Firehose delivery stream used for WAF logs. |
| <a name="output_firehose_delivery_stream_id"></a> [firehose\_delivery\_stream\_id](#output\_firehose\_delivery\_stream\_id) | The ID of the Kinesis Firehose delivery stream used for WAF logs. |
| <a name="output_log_bucket_arn"></a> [log\_bucket\_arn](#output\_log\_bucket\_arn) | The ARN of the S3 bucket used for WAF logs. |
| <a name="output_log_bucket_id"></a> [log\_bucket\_id](#output\_log\_bucket\_id) | The ID of the S3 bucket used for WAF logs. |
| <a name="output_web_acl_arn"></a> [web\_acl\_arn](#output\_web\_acl\_arn) | The ARN of the WAF WebACL. |
| <a name="output_web_acl_capacity"></a> [web\_acl\_capacity](#output\_web\_acl\_capacity) | The capacity of the WAF WebACL. |
| <a name="output_web_acl_id"></a> [web\_acl\_id](#output\_web\_acl\_id) | The ID of the WAF WebACL. |
<!-- END_TF_DOCS -->
