# CloudWatch Logging Module for WAF

This module creates CloudWatch Log Group resources to be used for WAF logging.

## Usage

```hcl
module "cloudwatch_logging" {
  source = "./modules/logging_dist_cloudwatch"
  
  name              = "my-waf-name"
  log_retention_days = 90
  region            = "us-west-2"
  account_id        = "123456789012"
  log_class         = "STANDARD"  # or "INFREQUENT_ACCESS"
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
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.waf_logging_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_iam_policy_document.log_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_log_class"></a> [log\_class](#input\_log\_class) | Log Class for CloudWatch Log Group. Valid values: STANDARD, INFREQUENT\_ACCESS | `string` | `"STANDARD"` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain WAF logs in CloudWatch | `number` | `90` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the WAF Web ACL (used for naming log group) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch log group used for WAF logs. |
| <a name="output_cloudwatch_log_group_class"></a> [cloudwatch\_log\_group\_class](#output\_cloudwatch\_log\_group\_class) | The storage class of the CloudWatch log group used for WAF logs. |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | The name of the CloudWatch log group used for WAF logs. |
<!-- END_TF_DOCS -->
