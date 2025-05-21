# S3 Bucket Logging Module for WAF

This module creates an S3 bucket to be used for WAF logging.

## Usage

```hcl
module "s3_logging" {
  source = "./modules/logging_dist_s3"
  
  name = "my-waf-name"
  
  # Intelligent-Tiering configuration (optional)
  enable_intelligent_tiering = true
  intelligent_tiering_days   = 30
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
| [aws_s3_bucket.log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.log_bucket_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Prefix for the S3 bucket name | `string` | `"aws-waf-logs-"` | no |
| <a name="input_enable_intelligent_tiering"></a> [enable\_intelligent\_tiering](#input\_enable\_intelligent\_tiering) | Enable Intelligent-Tiering storage class for logs | `bool` | `true` | no |
| <a name="input_enable_kms"></a> [enable\_kms](#input\_enable\_kms) | Whether to enable KMS encryption for the S3 bucket | `bool` | `false` | no |
| <a name="input_intelligent_tiering_days"></a> [intelligent\_tiering\_days](#input\_intelligent\_tiering\_days) | Number of days after which logs will be moved to Intelligent-Tiering storage class | `number` | `30` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key to use for encrypting the S3 bucket. If not specified but enable\_kms is true, the AWS managed key will be used. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the WAF Web ACL (used for bucket naming) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket used for WAF logs. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The ID of the S3 bucket used for WAF logs. |
<!-- END_TF_DOCS -->
