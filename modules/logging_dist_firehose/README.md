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
  
  # Timezone configuration for S3 prefixes
  s3_prefix_timezone              = "UTC"  # Default timezone
  s3_error_output_prefix_timezone = "UTC"  # Default timezone
  
  # Error logging configuration
  enable_error_logging     = true
  error_log_group_name     = "firehose-error-logs" # Optional custom name
  error_log_retention_days = 14
  
  # Processing configuration
  enable_processing = true
  processors = [
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
```

### Timezone Configuration Example

```hcl
module "firehose_logging_with_timezone" {
  source = "./modules/logging_dist_firehose"
  
  name = "my-waf-with-timezone"
  
  # S3 destination configuration
  log_bucket_arn = "arn:aws:s3:::existing-bucket-name"
  
  # Buffer settings
  firehose_buffer_interval = 60    # 1 minute
  firehose_buffer_size     = 5     # 5 MB
  
  # S3 prefix with Asia/Tokyo timezone
  log_s3_prefix            = "waf-logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  s3_prefix_timezone       = "Asia/Tokyo"  # Date patterns will be evaluated in Tokyo timezone
  
  # Error output prefix with Asia/Tokyo timezone
  log_s3_error_output_prefix          = "waf-errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
  s3_error_output_prefix_timezone     = "Asia/Tokyo"  # Date patterns will be evaluated in Tokyo timezone
  
  # Enable error logging to CloudWatch
  enable_error_logging     = true
  error_log_retention_days = 7
}
```

### Custom Processing Configuration Example

```hcl
module "firehose_with_custom_processing" {
  source = "./modules/logging_dist_firehose"
  
  name = "my-waf-with-custom-processing"
  log_bucket_arn = "arn:aws:s3:::existing-bucket-name"
  
  # Enable processing with custom processors
  enable_processing = true
  processors = [
    {
      # Format conversion processor (example)
      type = "RecordDeAggregation"
      parameters = [
        {
          parameter_name  = "SubRecordType"
          parameter_value = "JSON"
        }
      ]
    },
    {
      # Data transformation processor (example)
      type = "MetadataExtraction"
      parameters = [
        {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        },
        {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{timestamp:.timestamp, sourceIp:.httpRequest.clientIp}"
        }
      ]
    },
    {
      # Append delimiter at the end
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
```

### Available Processor Types

| Processor Type | Description | Common Parameters | Use Case |
|----------------|-------------|-------------------|----------|
| `AppendDelimiterToRecord` | Adds a delimiter character to the end of each record | `Delimiter` (e.g., `\\n`) | Ensuring records have line breaks |
| `MetadataExtraction` | Extracts specified fields from JSON records | `JsonParsingEngine`, `MetadataExtractionQuery` | Extracting key fields for analytics |
| `RecordDeAggregation` | Splits aggregated records | `SubRecordType` (e.g., `JSON`) | Working with aggregated logs |
| `Lambda` | Applies custom transformations with AWS Lambda | `LambdaArn`, `RoleArn`, `BufferSizeInMBs` | Complex custom transformations |
| `DataFormatConversion` | Converts between data formats | `SchemaConfiguration`, `InputFormatConfiguration`, `OutputFormatConfiguration` | Converting to formats like Parquet |

For detailed information on each processor type and parameters, refer to the [AWS Kinesis Firehose documentation](https://docs.aws.amazon.com/firehose/latest/dev/data-transformation.html).

### Validation Rules

This module includes several validation rules to help prevent common configuration errors:

1. **Processor Type Validation**: Only the following processor types are allowed:
   - `AppendDelimiterToRecord`
   - `MetadataExtraction`
   - `RecordDeAggregation`
   - `Lambda`
   - `DataFormatConversion`

2. **Parameter Name Validation**:
   - For `AppendDelimiterToRecord`, only the `Delimiter` parameter is allowed
   - For `MetadataExtraction`, only `JsonParsingEngine` and `MetadataExtractionQuery` parameters are allowed

These validations help catch configuration errors early in the deployment process.

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
| [aws_cloudwatch_log_group.firehose_error_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.firehose_error_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_iam_role.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kinesis_firehose_delivery_stream.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_iam_policy_document.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.firehose_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_error_logging"></a> [enable\_error\_logging](#input\_enable\_error\_logging) | Enable CloudWatch Logs for error logging of the Firehose delivery stream | `bool` | `true` | no |
| <a name="input_enable_processing"></a> [enable\_processing](#input\_enable\_processing) | Enable processing configuration for Firehose delivery stream | `bool` | `true` | no |
| <a name="input_error_log_group_name"></a> [error\_log\_group\_name](#input\_error\_log\_group\_name) | CloudWatch Log group name for Firehose error logs. If empty, 'aws-waf-logs-error-{var.name}' will be used. | `string` | `""` | no |
| <a name="input_error_log_retention_days"></a> [error\_log\_retention\_days](#input\_error\_log\_retention\_days) | Number of days to retain Firehose error logs in CloudWatch | `number` | `14` | no |
| <a name="input_firehose_buffer_interval"></a> [firehose\_buffer\_interval](#input\_firehose\_buffer\_interval) | Buffer interval for Firehose in seconds (60-900) | `number` | `300` | no |
| <a name="input_firehose_buffer_size"></a> [firehose\_buffer\_size](#input\_firehose\_buffer\_size) | Buffer size for Firehose in MB (1-128) | `number` | `128` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key to use for encrypting logs | `string` | `""` | no |
| <a name="input_log_bucket_arn"></a> [log\_bucket\_arn](#input\_log\_bucket\_arn) | ARN of an existing S3 bucket to use for logs | `string` | `""` | no |
| <a name="input_log_bucket_keys"></a> [log\_bucket\_keys](#input\_log\_bucket\_keys) | Enable KMS key access to S3 bucket for log encryption | `bool` | `false` | no |
| <a name="input_log_s3_error_output_prefix"></a> [log\_s3\_error\_output\_prefix](#input\_log\_s3\_error\_output\_prefix) | S3 prefix for WAF error logs | `string` | `"waf-fulllog-error/"` | no |
| <a name="input_log_s3_prefix"></a> [log\_s3\_prefix](#input\_log\_s3\_prefix) | S3 prefix for WAF logs | `string` | `"waf-fulllog/"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the WAF Web ACL (used for Firehose naming) | `string` | n/a | yes |
| <a name="input_processors"></a> [processors](#input\_processors) | List of processors for Firehose delivery stream. Each processor has a type and list of parameters. Default is a simple AppendDelimiterToRecord processor. | <pre>list(object({<br/>    type = string<br/>    parameters = list(object({<br/>      parameter_name  = string<br/>      parameter_value = string<br/>    }))<br/>  }))</pre> | <pre>[<br/>  {<br/>    "parameters": [<br/>      {<br/>        "parameter_name": "Delimiter",<br/>        "parameter_value": "\\n"<br/>      }<br/>    ],<br/>    "type": "AppendDelimiterToRecord"<br/>  }<br/>]</pre> | no |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | ARN of the S3 bucket created in the S3 module | `string` | `""` | no |
| <a name="input_s3_error_output_prefix_timezone"></a> [s3\_error\_output\_prefix\_timezone](#input\_s3\_error\_output\_prefix\_timezone) | Timezone for S3 error output prefix date formatting. Sets the custom\_time\_zone parameter for error output prefix formatting. Valid timezone values follow the IANA Time Zone Database format (e.g., 'UTC', 'America/New\_York', 'Asia/Tokyo', 'Europe/London', etc.). This affects how date patterns in the error output S3 prefix are interpreted. | `string` | `"UTC"` | no |
| <a name="input_s3_prefix_timezone"></a> [s3\_prefix\_timezone](#input\_s3\_prefix\_timezone) | Timezone for S3 prefix date formatting. Sets the custom\_time\_zone parameter for Firehose's extended\_s3\_configuration. Valid timezone values follow the IANA Time Zone Database format (e.g., 'UTC', 'America/New\_York', 'Asia/Tokyo', 'Europe/London', etc.). This affects how date patterns in the S3 prefix are interpreted. | `string` | `"UTC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_error_log_group_arn"></a> [error\_log\_group\_arn](#output\_error\_log\_group\_arn) | The ARN of the CloudWatch Log group used for Firehose error logs. |
| <a name="output_error_log_group_name"></a> [error\_log\_group\_name](#output\_error\_log\_group\_name) | The name of the CloudWatch Log group used for Firehose error logs. |
| <a name="output_firehose_delivery_stream_arn"></a> [firehose\_delivery\_stream\_arn](#output\_firehose\_delivery\_stream\_arn) | The ARN of the Kinesis Firehose delivery stream used for WAF logs. |
| <a name="output_firehose_delivery_stream_id"></a> [firehose\_delivery\_stream\_id](#output\_firehose\_delivery\_stream\_id) | The ID of the Kinesis Firehose delivery stream used for WAF logs. |
<!-- END_TF_DOCS -->

## Troubleshooting

### Common Issues and Solutions

#### No Logs Appearing in S3

If WAF logs aren't appearing in the S3 bucket:

1. **Check IAM Permissions**: Ensure the Firehose role has correct S3 permissions
   ```bash
   aws iam get-policy-document --policy-arn <firehose-role-policy-arn>
   ```

2. **Verify Firehose Delivery Stream Status**: Check that the delivery stream is active
   ```bash
   aws firehose describe-delivery-stream --delivery-stream-name aws-waf-logs-<your-waf-name>
   ```

3. **Check CloudWatch Error Logs**: Review the error logs if error logging is enabled
   ```bash
   aws logs get-log-events --log-group-name <error-log-group-name> --log-stream-name S3Delivery
   ```

#### Processing Configuration Issues

If your processing configuration isn't working as expected:

1. **Validate Processor Parameters**: Ensure all parameters are correctly specified
2. **Check for Processing Errors**: Review CloudWatch error logs for processing failures
3. **Test with Simple Configuration**: Start with a basic processor (like AppendDelimiterToRecord) before adding more complex ones

#### S3 Prefix Time Zone Issues

If date patterns in S3 prefixes aren't reflecting the configured timezone:

1. **Verify S3 Prefix Format**: Ensure your prefix includes valid timestamp patterns (e.g., `!{timestamp:yyyy-MM-dd}`)
2. **Check Time Zone Validity**: Ensure you're using a valid IANA Time Zone Database name
3. **Inspect Sample Logs**: Check the prefixes of files already delivered to S3

### Advanced Diagnostics

To diagnose Firehose delivery issues in detail:

```bash
# Get detailed metrics for your Firehose delivery stream
aws cloudwatch get-metric-statistics \
  --metric-name DeliveryToS3.Success \
  --namespace AWS/Firehose \
  --dimensions Name=DeliveryStreamName,Value=aws-waf-logs-<your-waf-name> \
  --start-time $(date -v-1d +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum

# Get processing failures if you're using Lambda processors
aws cloudwatch get-metric-statistics \
  --metric-name ProcessingFailures \
  --namespace AWS/Firehose \
  --dimensions Name=DeliveryStreamName,Value=aws-waf-logs-<your-waf-name> \
  --start-time $(date -v-1d +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```
