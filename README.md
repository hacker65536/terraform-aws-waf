# AWS WAF Module with Multiple Logging Options

This Terraform module manages AWS### Advanced Firehose Features

## S3 Prefix Timezone Configuration

When using the Firehose logging option, this module supports custom timezone configuration for S3 prefixes. This allows you to format date patterns in S3 prefixes using a timezone other than UTC.

### How It Works

The module sets the `custom_time_zone` parameter in the Firehose's extended S3 configuration. This affects how date patterns like `!{timestamp:yyyy-MM-dd}` are evaluated in the S3 prefixes.

### Benefits

- **Regional Compliance**: Store logs with timestamps matching your region's timezone
- **Simplified Log Analysis**: Avoid timezone conversion when analyzing logs
- **Organized Storage**: Create intuitive folder structures based on local time

### Example Usage

```hclon Firewall) resources with flexible logging options.

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

## Available Examples

This module includes several examples to demonstrate different use cases:

1. **Multiple Logging Options**: Demonstrates all three logging destinations
   - Path: `examples/multiple-logging-options/`
   - Features: CloudWatch Logs, S3 Bucket, and Kinesis Firehose

2. **Timezone and Processing Configuration**: Shows time zone settings and basic processing
   - Path: `examples/timezone-test/`
   - Features: Configuring Asia/Tokyo timezone and metadata extraction

3. **Advanced Firehose Processing**: Demonstrates comprehensive data processing pipeline
   - Path: `examples/advanced-processing/`
   - Features: Record deaggregation, metadata extraction, format conversion, and data transformation

4. **Athena Integration**: Shows how to integrate WAF logs with Amazon Athena for SQL-based analysis
   - Path: `examples/athena-integration/`
   - Features: Glue Data Catalog, Parquet conversion, partitioning, and sample Athena queries
   
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

## Advanced Firehose Features

### S3 Prefix Timezone Configuration

When using the Firehose logging option, this module supports custom timezone configuration for S3 prefixes. This allows you to format date patterns in S3 prefixes using a timezone other than UTC.

### How It Works

The module sets the `custom_time_zone` parameter in the Firehose's extended S3 configuration. This affects how date patterns like `!{timestamp:yyyy-MM-dd}` are evaluated in the S3 prefixes.

### Benefits

- **Regional Compliance**: Store logs with timestamps matching your region's timezone
- **Simplified Log Analysis**: Avoid timezone conversion when analyzing logs
- **Organized Storage**: Create intuitive folder structures based on local time

### Example Usage

```hcl
module "waf" {
  source = "path/to/module"
  
  # ... other configuration ...
  
  # Enable Firehose logging
  logging_dist_firehose = true
  
  # Configure S3 prefixes with Tokyo timezone
  log_s3_prefix                       = "waf-logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  log_s3_prefix_timezone              = "Asia/Tokyo"  # Format dates using Tokyo timezone
  log_s3_error_output_prefix          = "waf-errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  log_s3_error_output_prefix_timezone = "Asia/Tokyo"  # Format error dates using Tokyo timezone
}
```

Valid timezone values follow the IANA Time Zone Database format (e.g., UTC, America/New_York, Europe/London, Asia/Tokyo).

### Custom Processing Configuration

## Firehose Data Processing Pipeline

The module supports configuring comprehensive data processing pipelines for the Firehose delivery stream. This allows you to transform, filter, enhance, and convert the WAF logs before they are delivered to S3, making downstream analysis and integration much more powerful.

### Available Processors

| Processor Type | Description | Common Use Cases |
|----------------|-------------|-----------------|
| `AppendDelimiterToRecord` | Adds a delimiter to the end of each record | Ensuring proper newline separation for log processing tools |
| `MetadataExtraction` | Extracts specific fields from JSON logs | Creating searchable metadata for faster queries |
| `RecordDeAggregation` | Splits aggregated records | Processing batch records individually |
| `Lambda` | Applies custom transformations via AWS Lambda | Complex processing logic not covered by other processors |
| `DataFormatConversion` | Converts between data formats | Converting JSON logs to Parquet for Athena integration |

### Processing Pipeline Benefits

- **Cost Optimization**: Filter out unnecessary data before storage
- **Query Performance**: Convert to columnar formats like Parquet for faster analytics
- **Integration Ready**: Extract metadata for seamless integration with other AWS services
- **Schema Evolution**: Prepare data for downstream schema requirements

### Example Processing Patterns

1. **Basic Processing**: Add newline delimiters to ensure proper record formatting
2. **Analytics Preparation**: Extract metadata and convert to Parquet for Athena queries
3. **Data Pipeline Ingestion**: Prepare data for Glue ETL or EMR processing
4. **Real-time Monitoring**: Extract critical fields for CloudWatch Metrics or custom dashboards

### Example Usage

```hcl
module "waf" {
  source = "path/to/module"
  
  # ... other configuration ...
  
  # Enable Firehose logging
  logging_dist_firehose = true
  
  # Custom Firehose processing
  firehose_enable_processing = true
  firehose_processors = [
    {
      # Step 1: Deaggregate any batch records
      type = "RecordDeAggregation"
      parameters = [
        {
          parameter_name  = "SubRecordType"
          parameter_value = "JSON"
        }
      ]
    },
    {
      # Step 2: Extract specific fields from WAF logs
      type = "MetadataExtraction"
      parameters = [
        {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        },
        {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{timestamp:.timestamp, sourceIp:.httpRequest.clientIp, uri:.httpRequest.uri, action:.action, ruleId:.terminatingRuleId}"
        }
      ]
    },
    {
      # Step 3: Convert to Parquet for analytics (requires AWS Glue Data Catalog setup)
      type = "DataFormatConversion"
      parameters = [
        {
          parameter_name  = "SchemaConfiguration"
          parameter_value = "{ \"CatalogId\": \"123456789012\", \"DatabaseName\": \"waf_logs\", \"TableName\": \"waf_logs_table\", \"Region\": \"us-east-1\" }"
        },
        {
          parameter_name  = "InputFormatConfiguration"
          parameter_value = "{ \"Deserializer\": { \"OpenXJsonSerDe\": { \"CaseInsensitive\": true } } }"
        },
        {
          parameter_name  = "OutputFormatConfiguration"
          parameter_value = "{ \"Serializer\": { \"ParquetSerDe\": { \"Compression\": \"SNAPPY\" } } }"
        }
      ]
    },
    {
      # Step 4: Always add newline delimiter to each record
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

For a complete example, see the [Advanced Processing Example](examples/advanced-processing/main.tf) included in this module.

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
  
  # Configure Firehose buffer settings
  firehose_buffer_interval = 60  # seconds
  firehose_buffer_size     = 5   # MB
}
```

### Kinesis Firehose with Custom Timezone and Error Logging

```hcl
module "waf_firehose_with_timezone" {
  source = "path/to/module"
  
  name        = "example-waf"
  description = "Example WAF with Firehose logging and custom timezone"
  scope       = "REGIONAL"
  
  # Enable only Firehose logging
  logging_dist_cloudwatch = false
  logging_dist_s3         = false
  logging_dist_firehose   = true
  
  # Firehose error logging to CloudWatch
  firehose_enable_error_logging     = true
  firehose_error_log_retention_days = 7
  firehose_error_log_group_name     = "aws-waf-firehose-errors"
  
  # S3 prefix with custom timezone configuration
  log_s3_prefix                       = "waf-logs/"
  log_s3_prefix_timezone              = "Asia/Tokyo"  # Use Tokyo timezone for logs
  log_s3_error_output_prefix          = "waf-errors/"
  log_s3_error_output_prefix_timezone = "Asia/Tokyo"  # Use Tokyo timezone for error logs
}
```

## Testing Your WAF Configuration

After deploying your WAF module, it's important to test the configuration to ensure logs are being delivered correctly to your chosen destination. Here are some testing strategies:

### 1. Generate Test Traffic

Generate sample traffic to your application to trigger WAF logging:

```bash
# Simple curl request to trigger WAF evaluation
curl -v https://your-application-endpoint.com/test?param1=test

# Send a request that might trigger a WAF rule (e.g., SQL injection pattern)
curl -v "https://your-application-endpoint.com/test?id=1' OR 1=1--"
```

### 2. Verify Logs in CloudWatch Logs

If using CloudWatch as your logging destination:

```bash
# List the most recent log events (AWS CLI)
aws logs get-log-events \
  --log-group-name "/aws/waf/example-waf" \
  --log-stream-name <log-stream-name> \
  --limit 10
```

### 3. Verify Logs in S3

If using S3 or Firehose as your logging destination:

```bash
# List objects in your logs bucket
aws s3 ls s3://your-bucket/waf-logs/

# Download and view a sample log file
aws s3 cp s3://your-bucket/waf-logs/<log-file> ./sample-log.gz
gunzip sample-log.gz
cat sample-log
```

### 4. Test Firehose Processing

For configurations with Firehose processing:

1. Check the Firehose delivery stream in the AWS Console
2. Verify that processed logs appear in the format you expect
3. If using Athena integration, run test queries against the processed data:

```sql
-- Athena query example for processed WAF logs
SELECT 
  timestamp,
  httpRequest.clientIp,
  httpRequest.country,
  httpRequest.uri,
  action
FROM waf_logs.waf_logs_table
LIMIT 10;
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
| <a name="input_firehose_enable_error_logging"></a> [firehose\_enable\_error\_logging](#input\_firehose\_enable\_error\_logging) | (Optional) Enable CloudWatch Logs for error logging of the Firehose delivery stream | `bool` | `true` | no |
| <a name="input_firehose_enable_processing"></a> [firehose\_enable\_processing](#input\_firehose\_enable\_processing) | (Optional) Enable processing configuration for Firehose delivery stream | `bool` | `true` | no |
| <a name="input_firehose_error_log_group_name"></a> [firehose\_error\_log\_group\_name](#input\_firehose\_error\_log\_group\_name) | (Optional) CloudWatch Log group name for Firehose error logs. If empty, a default name will be used. | `string` | `""` | no |
| <a name="input_firehose_error_log_retention_days"></a> [firehose\_error\_log\_retention\_days](#input\_firehose\_error\_log\_retention\_days) | (Optional) Number of days to retain Firehose error logs in CloudWatch | `number` | `14` | no |
| <a name="input_firehose_processors"></a> [firehose\_processors](#input\_firehose\_processors) | (Optional) List of processors for Firehose delivery stream. Each processor has a type and list of parameters. | <pre>list(object({<br/>    type = string<br/>    parameters = list(object({<br/>      parameter_name  = string<br/>      parameter_value = string<br/>    }))<br/>  }))</pre> | <pre>[<br/>  {<br/>    "parameters": [<br/>      {<br/>        "parameter_name": "Delimiter",<br/>        "parameter_value": "\\n"<br/>      }<br/>    ],<br/>    "type": "AppendDelimiterToRecord"<br/>  }<br/>]</pre> | no |
| <a name="input_intelligent_tiering_days"></a> [intelligent\_tiering\_days](#input\_intelligent\_tiering\_days) | (Optional) Number of days after which logs will be moved to Intelligent-Tiering storage class | `number` | `30` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | (Optional) ARN of KMS key to use for encrypting logs. | `string` | `""` | no |
| <a name="input_log_bucket_arn"></a> [log\_bucket\_arn](#input\_log\_bucket\_arn) | ARN of an existing S3 bucket to use for logs | `string` | `""` | no |
| <a name="input_log_bucket_keys"></a> [log\_bucket\_keys](#input\_log\_bucket\_keys) | (Optional) If true, enables KMS key access to S3 bucket for log encryption. | `bool` | `false` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | (Optional) Number of days to retain WAF logs in CloudWatch. | `number` | `90` | no |
| <a name="input_log_s3_error_output_prefix"></a> [log\_s3\_error\_output\_prefix](#input\_log\_s3\_error\_output\_prefix) | S3 prefix for WAF error logs. A trailing slash (/) is required. | `string` | `"waf-fulllog-error/"` | no |
| <a name="input_log_s3_error_output_prefix_timezone"></a> [log\_s3\_error\_output\_prefix\_timezone](#input\_log\_s3\_error\_output\_prefix\_timezone) | (Optional) Timezone for S3 error output prefix date formatting in Firehose. This sets the custom\_time\_zone parameter for error output paths. Valid values include timezones like 'UTC', 'America/New\_York', 'Asia/Tokyo', 'Europe/London', etc. See the IANA Time Zone Database for valid values. | `string` | `"UTC"` | no |
| <a name="input_log_s3_prefix"></a> [log\_s3\_prefix](#input\_log\_s3\_prefix) | S3 prefix for WAF logs. A trailing slash (/) is required. | `string` | `"waf-fulllog/"` | no |
| <a name="input_log_s3_prefix_timezone"></a> [log\_s3\_prefix\_timezone](#input\_log\_s3\_prefix\_timezone) | (Optional) Timezone for S3 prefix date formatting in Firehose. This sets the custom\_time\_zone parameter for Firehose delivery, affecting how date patterns in S3 prefixes are evaluated. Valid values include timezones like 'UTC', 'America/New\_York', 'Asia/Tokyo', 'Europe/London', etc. See the IANA Time Zone Database for valid values. | `string` | `"UTC"` | no |
| <a name="input_logging_dist_cloudwatch"></a> [logging\_dist\_cloudwatch](#input\_logging\_dist\_cloudwatch) | (Optional) If true, all WebACL traffic will be logged to CloudWatch. Only one of logging\_dist\_cloudwatch, logging\_dist\_s3, or logging\_dist\_firehose can be true. | `bool` | `false` | no |
| <a name="input_logging_dist_firehose"></a> [logging\_dist\_firehose](#input\_logging\_dist\_firehose) | (Optional) If true, all WebACL traffic will be logged to Kinesis Firehose. Only one of logging\_dist\_cloudwatch, logging\_dist\_s3, or logging\_dist\_firehose can be true. | `bool` | `false` | no |
| <a name="input_logging_dist_s3"></a> [logging\_dist\_s3](#input\_logging\_dist\_s3) | (Optional) If true, all WebACL traffic will be logged to S3. Only one of logging\_dist\_cloudwatch, logging\_dist\_s3, or logging\_dist\_firehose can be true. | `bool` | `false` | no |
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
