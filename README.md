# AWS WAF Module with Multiple Logging Options

[![Release](https://img.shields.io/github/v/release/go-sujun/terraform-aws-waf?style=flat-square)](https://github.com/go-sujun/terraform-aws-waf/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Languages](https://img.shields.io/badge/Languages-EN_|_JA-blue)](./README_JP.md)

This Terraform module configures an AWS Web Application Firewall (WAF) with multiple logging destination options, flexible configuration, and enhanced security features.

*Read this in: [English](README.md), [日本語](README_JP.md)*

## Features

- **Flexible Logging Options**: Deploy with your choice of destination:
  - CloudWatch Logs
  - S3 Bucket
  - Kinesis Firehose with advanced processing
- **Enhanced Security**:
  - KMS encryption for all logging destinations
  - IAM least-privilege permissions
  - Log field redaction and filtering capabilities
- **Advanced Capabilities**:
  - Firehose processing pipeline with multiple processors (record deaggregation, metadata extraction, format conversion)
  - Configurable S3 prefix timezones for regional compliance
  - Intelligent-Tiering for S3 buckets to optimize storage costs
  - Athena integration with Parquet format support
- **Complete Modularity**:
  - Dedicated submodules for each logging type
  - Support for both Terraform-managed and WAF Charm-managed WAFs
  - Easily extensible architecture

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

4. **KMS Encryption**: Shows how to enable KMS encryption for logs
   - Path: `examples/kms-encryption/`
   - Features: Customer-managed KMS keys, encryption settings for all log destinations

## Documentation

For detailed information about specific features, please refer to the following documentation:

- [Architecture Overview](docs/ARCHITECTURE.md): High-level design and component interactions
- [Firehose Processing Guide](docs/firehose-processing.md): Advanced Firehose configuration options
- [Timezone Configuration](docs/timezone-config.md): S3 prefix timezone settings
- [Athena Integration](docs/athena-integration.md): Analyzing WAF logs using Athena

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

### Firehose Data Processing Pipeline

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

## KMS Encryption Support

This module supports KMS encryption for WAF logs across all logging destinations:

- **S3 Bucket**: Server-side encryption using KMS
- **Firehose Stream**: Encryption in transit and at rest using KMS
- **CloudWatch Logs**: Encryption using KMS

### How to Enable KMS Encryption

```hcl
module "waf" {
  source = "path/to/module"
  
  # Basic configuration
  name   = "example-waf"
  scope  = "REGIONAL"
  
  # Enable logging destination
  logging_dist_s3 = true
  
  # Enable KMS encryption for S3/Firehose
  log_bucket_keys = true
  kms_key_arn     = "arn:aws:kms:region:account:key/key-id" # Optional
  
  # Enable KMS encryption for CloudWatch (if using CloudWatch logs)
  cloudwatch_enable_kms = true
}
```

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

### Kinesis Firehose with Metadata Extraction

```hcl
module "waf" {
  source = "path/to/module"
  
  # Enable Firehose logging
  logging_dist_firehose = true
  
  # Enable Firehose processing
  firehose_enable_processing = true
  
  # Configure processors
  firehose_processors = [
    {
      type = "MetadataExtraction"
      parameters = [
        {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{action:.action,ruleid:.ruleId}"
        },
        {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
      ]
    }
  ]
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