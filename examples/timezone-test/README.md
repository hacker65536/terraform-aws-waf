# Advanced Firehose Configuration Example

This example demonstrates advanced configuration options for the AWS WAF Firehose logging system, including custom timezones for S3 prefixes and customized processing configuration.

## Description

This example showcases two key features:

1. **Custom Timezone Configuration**: When using Firehose logging, you can specify a custom timezone for date patterns in S3 prefixes.
2. **Advanced Processing Configuration**: The example demonstrates how to customize data processing before logs are delivered to S3.

## Features Demonstrated

### S3 Prefix Timezone Features
- Store logs with timestamps matching your region's timezone (Asia/Tokyo in this example)
- Simplify log analysis by avoiding timezone conversion
- Create intuitive folder structures based on local time

### Processing Configuration Features
- Metadata extraction from WAF logs to enhance searchability
- Lambda transformation for custom log enrichment
- Record format transformation and delimiter handling

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Explanation

### Timezone Configuration

The example configures S3 prefixes with the Japan Standard Time timezone:

1. Setting `log_s3_prefix_timezone` and `log_s3_error_output_prefix_timezone` to "Asia/Tokyo"
2. Using date patterns like `!{timestamp:yyyy}` in the S3 prefixes
3. The resulting S3 folder structure will use timestamps in JST rather than UTC

### Processing Configuration

The example also demonstrates an advanced processing pipeline:

1. **Metadata Extraction**: 
   - Extracts important fields from WAF logs (timestamp, action, ruleId, etc.)
   - Uses JQ-1.6 parsing engine for efficient processing

2. **Lambda Transformation** (placeholder example):
   - Shows how to integrate a Lambda function for custom processing
   - Includes configuration for retries, buffering, and IAM roles

3. **Record Formatting**:
   - Ensures records are properly formatted with newlines
   - Maintains compatibility with downstream analysis tools

This processing pipeline enables more efficient storage, better organization, and enhanced analytics capabilities for your WAF logs.
