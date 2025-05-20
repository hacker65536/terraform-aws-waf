# Timezone Configuration for S3 Prefixes

This document explains how to configure custom timezones for S3 prefixes when using Kinesis Firehose for WAF logging.

## Overview

When using Kinesis Firehose to deliver AWS WAF logs to S3, you can include date patterns in your S3 prefixes. By default, these date patterns are evaluated in the UTC timezone. However, you may want to organize your logs based on a different timezone, such as your local timezone or the timezone where your application is primarily used.

## Benefits of Custom Timezone Configuration

1. **Regional Compliance**: Store logs with timestamps matching your region's timezone for easier compliance with local regulations
2. **Simplified Log Analysis**: Avoid timezone conversion when analyzing logs in your local timezone
3. **Organized Storage**: Create intuitive folder structures based on local time for better organization

## Configuration Parameters

This module provides two variables for timezone configuration:

1. `log_s3_prefix_timezone` - Controls timezone for the main log prefix
2. `log_s3_error_output_prefix_timezone` - Controls timezone for error output prefix

Both variables accept timezone values from the IANA Time Zone Database, such as:
- `UTC` (default)
- `America/New_York`
- `Europe/London`
- `Asia/Tokyo`
- `Australia/Sydney`

## S3 Prefix Date Patterns

Firehose supports date patterns in S3 prefixes using the `!{timestamp:FORMAT}` syntax, where `FORMAT` follows Java's SimpleDateFormat patterns:

| Pattern | Description | Example Output |
|---------|-------------|----------------|
| yyyy | 4-digit year | 2025 |
| MM | 2-digit month | 05 |
| dd | 2-digit day | 20 |
| HH | 2-digit hour (24h) | 15 |
| mm | 2-digit minute | 30 |
| ss | 2-digit second | 45 |

## Example Configurations

### Basic Timezone Configuration

```hcl
module "waf" {
  source = "path/to/module"
  
  # ... other configuration ...
  
  # Enable Firehose logging
  logging_dist_firehose = true
  
  # Configure S3 prefixes with Tokyo timezone
  log_s3_prefix                       = "waf-logs/"
  log_s3_prefix_timezone              = "Asia/Tokyo"
  log_s3_error_output_prefix          = "waf-errors/"
  log_s3_error_output_prefix_timezone = "Asia/Tokyo"
}
```

### Partitioned Folder Structure with Custom Timezone

```hcl
module "waf" {
  source = "path/to/module"
  
  # ... other configuration ...
  
  # Enable Firehose logging
  logging_dist_firehose = true
  
  # Configure S3 prefixes with New York timezone and folder partitioning
  log_s3_prefix                 = "waf-logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
  log_s3_prefix_timezone        = "America/New_York"
  
  # Error prefix with the same timezone
  log_s3_error_output_prefix          = "waf-errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  log_s3_error_output_prefix_timezone = "America/New_York"
}
```

### Different Timezones for Main Logs and Error Logs

```hcl
module "waf" {
  source = "path/to/module"
  
  # ... other configuration ...
  
  # Enable Firehose logging
  logging_dist_firehose = true
  
  # Main logs in Tokyo timezone (for an application serving Asian users)
  log_s3_prefix          = "waf-logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  log_s3_prefix_timezone = "Asia/Tokyo"
  
  # Error logs in UTC (for global DevOps team)
  log_s3_error_output_prefix          = "waf-errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  log_s3_error_output_prefix_timezone = "UTC"
}
```

## Implementation Details

Under the hood, this module sets the `custom_time_zone` parameter in the Firehose's extended S3 configuration. This affects how date patterns like `!{timestamp:yyyy-MM-dd}` are evaluated in the S3 prefixes.

## Testing Timezone Configuration

After deploying your WAF module with custom timezone configuration, you should verify that logs are being delivered with the correct timestamp-based prefixes:

```bash
# List objects in your logs bucket to see folder structure
aws s3 ls s3://your-bucket/waf-logs/

# For partitioned folders, check specific date paths
aws s3 ls s3://your-bucket/waf-logs/year=2025/month=05/day=20/
```

## Common Issues

1. **Invalid Timezone**: Ensure you're using valid IANA timezone names
2. **Inconsistent Date Patterns**: Make sure all date patterns in your prefix follow Java's SimpleDateFormat
3. **Permissions**: Verify that Firehose has appropriate S3 permissions to write to the specified prefixes

For more examples, see the [Timezone Test Example](../examples/timezone-test/main.tf) included in this module.
