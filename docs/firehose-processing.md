# Firehose Processing Pipeline Configuration

This document provides a detailed guide on configuring the Firehose processing pipeline for AWS WAF logs.

## Overview

AWS WAF logs can be processed in transit using Kinesis Firehose's data processing capabilities. This allows you to transform, filter, and enhance the logs before they are delivered to S3, making downstream analysis more efficient.

## Processing Components

The processing pipeline consists of the following components:

1. **Processors**: Types of transformations to apply to the data
2. **Parameters**: Configuration options for each processor
3. **Execution Order**: Sequence in which processors are applied

## Available Processors

### 1. Record Deaggregation

Splits aggregated records into individual records.

**Use Case**: When receiving batched records that need to be processed individually.

**Example Configuration**:
```hcl
{
  type = "RecordDeAggregation"
  parameters = [
    {
      parameter_name  = "SubRecordType"
      parameter_value = "JSON"
    }
  ]
}
```

### 2. Metadata Extraction

Extracts specific fields from JSON records to create searchable metadata.

**Use Case**: Creating indexed fields for faster querying or organizing logs by specific attributes.

**Example Configuration**:
```hcl
{
  type = "MetadataExtraction"
  parameters = [
    {
      parameter_name  = "JsonParsingEngine"
      parameter_value = "JQ-1.6"
    },
    {
      parameter_name  = "MetadataExtractionQuery"
      parameter_value = "{timestamp:.timestamp, sourceIp:.httpRequest.clientIp, uri:.httpRequest.uri}"
    }
  ]
}
```

### 3. Data Format Conversion

Converts between data formats, particularly useful for converting JSON to columnar formats like Parquet.

**Use Case**: Preparing data for analytics services like Athena, which perform better with columnar formats.

**Example Configuration**:
```hcl
{
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
}
```

### 4. Lambda Transformation

Applies custom transformations using AWS Lambda functions.

**Use Case**: Complex processing logic not covered by other processors, such as enrichment with external data.

**Example Configuration**:
```hcl
{
  type = "Lambda"
  parameters = [
    {
      parameter_name  = "LambdaArn"
      parameter_value = "arn:aws:lambda:us-east-1:123456789012:function:waf-log-transformer"
    },
    {
      parameter_name  = "RoleArn"
      parameter_value = "arn:aws:iam::123456789012:role/firehose-lambda-role"
    },
    {
      parameter_name  = "BufferSizeInMBs"
      parameter_value = "3"
    }
  ]
}
```

### 5. Append Delimiter to Record

Adds a delimiter character to the end of each record.

**Use Case**: Ensuring records have proper line breaks for downstream processing.

**Example Configuration**:
```hcl
{
  type = "AppendDelimiterToRecord"
  parameters = [
    {
      parameter_name  = "Delimiter"
      parameter_value = "\\n"
    }
  ]
}
```

## Processing Order and Best Practices

1. **Recommended Processing Order**:
   - Start with `RecordDeAggregation` to split batched records
   - Apply `MetadataExtraction` or `Lambda` for data transformation
   - Use `DataFormatConversion` if changing formats
   - End with `AppendDelimiterToRecord` to ensure proper record formatting

2. **Performance Considerations**:
   - More complex processing increases delivery latency
   - Lambda transformations have the highest overhead
   - Data format conversion can significantly increase CPU utilization

3. **Error Handling**:
   - Enable error logging to CloudWatch Logs
   - Configure appropriate buffer settings based on your processing complexity
   - Test with representative data volumes before production deployment

## Example: Complete Processing Pipeline

Here's a complete example of a processing pipeline that prepares WAF logs for Athena queries:

```hcl
firehose_processors = [
  {
    # Step 1: Deaggregate records
    type = "RecordDeAggregation"
    parameters = [
      {
        parameter_name  = "SubRecordType"
        parameter_value = "JSON"
      }
    ]
  },
  {
    # Step 2: Extract key metadata
    type = "MetadataExtraction"
    parameters = [
      {
        parameter_name  = "JsonParsingEngine"
        parameter_value = "JQ-1.6"
      },
      {
        parameter_name  = "MetadataExtractionQuery"
        parameter_value = "{timestamp:.timestamp, clientIp:.httpRequest.clientIp, country:.httpRequest.country, uri:.httpRequest.uri, action:.action, ruleId:.terminatingRuleId}"
      }
    ]
  },
  {
    # Step 3: Convert to Parquet for Athena
    type = "DataFormatConversion"
    parameters = [
      {
        parameter_name  = "SchemaConfiguration"
        parameter_value = jsonencode({
          CatalogId    = "123456789012"
          DatabaseName = "waf_logs"
          TableName    = "waf_logs_table"
          Region       = "us-east-1"
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
  },
  {
    # Step 4: Add newline delimiter
    type = "AppendDelimiterToRecord"
    parameters = [
      {
        parameter_name  = "Delimiter"
        parameter_value = "\\n"
      }
    ]
  }
]
```

For more examples, see the [Advanced Processing Example](../examples/advanced-processing/main.tf) included in this module.
