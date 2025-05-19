# Firehose Logging Module for WAF

This module creates Kinesis Firehose resources to be used for WAF logging to S3.

## Usage

```hcl
module "firehose_logging" {
  source = "./modules/logging_dist_firehose"
  
  name                     = "my-waf-name"
  log_bucket_arn           = "arn:aws:s3:::existing-bucket-name" # Optional: Existing S3 bucket
  s3_bucket_arn            = module.s3_logging.s3_bucket_arn # Only needed if log_bucket_arn is empty
  log_bucket_keys          = false # Set to true if using KMS encryption
  kms_key_arn              = "" # Only needed if log_bucket_keys is true
  firehose_buffer_interval = 300
  firehose_buffer_size     = 128
  log_s3_prefix            = "waf-logs/"
  log_s3_error_output_prefix = "waf-errors/"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kinesis_firehose_delivery_stream.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_iam_policy_document.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.firehose_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firehose_buffer_interval"></a> [firehose\_buffer\_interval](#input\_firehose\_buffer\_interval) | Buffer interval for Firehose in seconds (60-900) | `number` | `300` | no |
| <a name="input_firehose_buffer_size"></a> [firehose\_buffer\_size](#input\_firehose\_buffer\_size) | Buffer size for Firehose in MB (1-128) | `number` | `128` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key to use for encrypting logs | `string` | `""` | no |
| <a name="input_log_bucket_arn"></a> [log\_bucket\_arn](#input\_log\_bucket\_arn) | ARN of an existing S3 bucket to use for logs | `string` | `""` | no |
| <a name="input_log_bucket_keys"></a> [log\_bucket\_keys](#input\_log\_bucket\_keys) | Enable KMS key access to S3 bucket for log encryption | `bool` | `false` | no |
| <a name="input_log_s3_error_output_prefix"></a> [log\_s3\_error\_output\_prefix](#input\_log\_s3\_error\_output\_prefix) | S3 prefix for WAF error logs | `string` | `"waf-fulllog-error/"` | no |
| <a name="input_log_s3_prefix"></a> [log\_s3\_prefix](#input\_log\_s3\_prefix) | S3 prefix for WAF logs | `string` | `"waf-fulllog/"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the WAF Web ACL (used for Firehose naming) | `string` | n/a | yes |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | ARN of the S3 bucket created in the S3 module | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firehose_delivery_stream_arn"></a> [firehose\_delivery\_stream\_arn](#output\_firehose\_delivery\_stream\_arn) | The ARN of the Kinesis Firehose delivery stream used for WAF logs. |
| <a name="output_firehose_delivery_stream_id"></a> [firehose\_delivery\_stream\_id](#output\_firehose\_delivery\_stream\_id) | The ID of the Kinesis Firehose delivery stream used for WAF logs. |
<!-- END_TF_DOCS -->
