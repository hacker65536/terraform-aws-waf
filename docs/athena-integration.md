# Integrating WAF Logs with Amazon Athena

This document explains how to configure the AWS WAF module for seamless integration with Amazon Athena, enabling SQL-based analysis of your WAF logs.

## Overview

Amazon Athena allows you to analyze AWS WAF logs using standard SQL queries, making it easy to extract insights about web traffic patterns, security threats, and application behavior. To optimize this integration, the WAF module supports configuring Kinesis Firehose to convert WAF logs from JSON to Parquet format, a columnar storage format that significantly improves query performance and reduces costs.

## Benefits of Athena Integration

1. **Cost Efficiency**: Parquet format reduces the amount of data scanned by Athena queries
2. **Query Performance**: Columnar storage enables faster query execution
3. **Simplified Analytics**: Use familiar SQL to analyze WAF logs
4. **Partitioned Data**: Time-based partitioning improves query performance and organization
5. **Visualization Integration**: Connect to AWS QuickSight or other visualization tools

## Implementation Steps

### 1. Create a Glue Database and Table

First, you need to create a Glue Data Catalog database and table to define the schema for your WAF logs:

```hcl
resource "aws_glue_catalog_database" "waf_logs_db" {
  name = "waf_logs_database"
}

resource "aws_glue_catalog_table" "waf_logs_table" {
  name          = "waf_logs"
  database_name = aws_glue_catalog_database.waf_logs_db.name
  
  table_type = "EXTERNAL_TABLE"
  
  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = "s3://your-bucket/waf-logs/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    
    ser_de_info {
      name                  = "ParquetHiveSerDe"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      
      parameters = {
        "serialization.format" = 1
      }
    }

    # Define schema columns based on WAF log structure
    columns {
      name = "timestamp"
      type = "timestamp"
    }
    columns {
      name = "action"
      type = "string"
    }
    # Add more columns as needed
  }
}
```

### 2. Configure the WAF Module with Firehose Processing

Next, configure the WAF module to use Firehose with data format conversion:

```hcl
module "waf" {
  source = "path/to/module"
  
  name        = "waf-with-athena"
  description = "WAF with Athena integration"
  scope       = "REGIONAL"
  
  # Enable Firehose logging
  logging_dist_cloudwatch = false
  logging_dist_s3         = false
  logging_dist_firehose   = true
  
  # S3 prefix with partitioning for efficient Athena queries
  log_s3_prefix = "waf-logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  
  # Enable processing with format conversion
  firehose_enable_processing = true
  firehose_processors = [
    {
      type = "DataFormatConversion"
      parameters = [
        {
          parameter_name  = "SchemaConfiguration"
          parameter_value = jsonencode({
            CatalogId    = data.aws_caller_identity.current.account_id
            DatabaseName = aws_glue_catalog_database.waf_logs_db.name
            TableName    = aws_glue_catalog_table.waf_logs_table.name
            Region       = data.aws_region.current.name
            VersionId    = "LATEST"
          })
        },
        {
          parameter_name  = "InputFormatConfiguration"
          parameter_value = jsonencode({
            Deserializer = {
              OpenXJsonSerDe = {
                CaseInsensitive = true
              }
            }
          })
        },
        {
          parameter_name  = "OutputFormatConfiguration"
          parameter_value = jsonencode({
            Serializer = {
              ParquetSerDe = {
                Compression = "SNAPPY"
              }
            }
          })
        }
      ]
    }
  ]
}
```

### 3. Create Athena Queries

Create pre-defined Athena queries to analyze your WAF logs:

```hcl
resource "aws_athena_named_query" "blocked_requests" {
  name        = "BlockedRequests"
  database    = aws_glue_catalog_database.waf_logs_db.name
  description = "Find all blocked requests"
  query       = <<-EOF
    SELECT
      from_unixtime(timestamp/1000) as request_time,
      httprequest.clientip as source_ip,
      httprequest.country as country,
      httprequest.uri as uri,
      terminatingruleid as rule_id
    FROM
      ${aws_glue_catalog_table.waf_logs_table.name}
    WHERE
      action = 'BLOCK'
    ORDER BY
      timestamp DESC
    LIMIT 100
  EOF
}
```

## Partitioning Strategy

Proper partitioning is crucial for Athena performance. We recommend:

1. **Time-based Partitioning**: Structure your S3 prefixes with year/month/day partitions
2. **Hive-compatible Format**: Use `key=value` format in S3 prefixes for automatic partition recognition
3. **Reasonable Partition Size**: Aim for partitions that contain 100MB-1GB of data

Example of a good partitioning structure:

```
s3://waf-logs-bucket/waf-logs/year=2025/month=05/day=20/
```

## Sample Athena Queries

### Top Blocked IP Addresses

```sql
SELECT
  httprequest.clientip as source_ip,
  COUNT(*) as block_count
FROM
  waf_logs.waf_logs_table
WHERE
  action = 'BLOCK'
GROUP BY
  httprequest.clientip
ORDER BY
  block_count DESC
LIMIT 10
```

### Geographic Distribution of Traffic

```sql
SELECT
  httprequest.country as country,
  COUNT(*) as request_count,
  COUNT(CASE WHEN action = 'BLOCK' THEN 1 END) as blocked_count
FROM
  waf_logs.waf_logs_table
WHERE
  year = '2025' AND month = '05'
GROUP BY
  httprequest.country
ORDER BY
  request_count DESC
```

### Top Triggered WAF Rules

```sql
SELECT
  terminatingruleid as rule_id,
  COUNT(*) as trigger_count
FROM
  waf_logs.waf_logs_table
WHERE
  action = 'BLOCK'
GROUP BY
  terminatingruleid
ORDER BY
  trigger_count DESC
LIMIT 10
```

## Cost Optimization Tips

1. **Use Parquet Format**: Reduces the amount of data scanned and improves performance
2. **Implement Partitioning**: Allows Athena to scan only relevant data
3. **Query Specific Columns**: Select only the columns you need rather than using `SELECT *`
4. **Filter by Partitions**: Always include partition columns in your WHERE clause
5. **Compress Data**: Use SNAPPY compression for a good balance of performance and size

For a complete example implementation, see the [Athena Integration Example](../examples/athena-integration/main.tf) included in this module.
