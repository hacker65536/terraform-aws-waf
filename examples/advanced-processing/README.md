# Advanced Firehose Processing Example

This example demonstrates how to configure advanced data processing features for AWS WAF logs using Kinesis Firehose.

## Description

When using Firehose for WAF logging, you can enhance the data pipeline with custom processors to transform, filter, and optimize your logs before they are stored in S3. This example showcases a comprehensive processing pipeline with multiple processors.

## Processing Pipeline

This example configures a 4-step processing pipeline:

1. **Record Deaggregation**
   - Converts records to a standard JSON format
   - Ensures consistent record structure for downstream processing

2. **Metadata Extraction**
   - Extracts important fields from WAF logs
   - Creates a metadata structure optimized for analytics
   - Focuses on key fields like client IP, country, URI, timestamp, and rule IDs

3. **Data Format Conversion**
   - Converts JSON logs to Parquet format using AWS Glue Data Catalog
   - Enables efficient querying with Amazon Athena
   - Applies SNAPPY compression for optimal storage

4. **Delimiter Insertion**
   - Ensures each record has a proper newline delimiter
   - Maintains compatibility with log analysis tools

## Benefits

- **Storage Efficiency**: Parquet format with compression reduces storage costs
- **Query Performance**: Optimized format for fast analytics with Athena
- **Flexible Structure**: Extracted metadata enables better organization
- **Integration Ready**: Prepared for integration with AWS analytics services

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Implementation Details

The key part of this example is the `firehose_processors` configuration that defines the processing pipeline:

```hcl
firehose_processors = [
  {
    type = "RecordDeAggregation"
    parameters = [{ parameter_name = "SubRecordType", parameter_value = "JSON" }]
  },
  {
    type = "MetadataExtraction"
    parameters = [
      { parameter_name = "JsonParsingEngine", parameter_value = "JQ-1.6" },
      { parameter_name = "MetadataExtractionQuery", parameter_value = "..." }
    ]
  },
  {
    type = "DataFormatConversion"
    parameters = [
      # AWS Glue Data Catalog configuration
      # Input format (JSON) and output format (Parquet)
    ]
  },
  {
    type = "AppendDelimiterToRecord"
    parameters = [{ parameter_name = "Delimiter", parameter_value = "\\n" }]
  }
]
```

The module handles the creation of all necessary resources including IAM roles and permissions.
