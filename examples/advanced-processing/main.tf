provider "aws" {
  region = "ap-northeast-1"
}

module "waf_with_advanced_processing" {
  source = "../../"

  name        = "advanced-processing-waf"
  description = "WAF with advanced Firehose processing configuration"
  scope       = "REGIONAL"

  # Enable Firehose logging only
  logging_dist_cloudwatch = false
  logging_dist_s3         = false
  logging_dist_firehose   = true

  # Basic Firehose settings
  firehose_buffer_interval   = 60
  firehose_buffer_size       = 5
  log_s3_prefix              = "waf-logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  log_s3_error_output_prefix = "waf-errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

  # Advanced processing configuration
  firehose_enable_processing = true
  firehose_processors = [
    {
      # Step 1: Convert record format if needed
      type = "RecordDeAggregation"
      parameters = [
        {
          parameter_name  = "SubRecordType"
          parameter_value = "JSON"
        }
      ]
    },
    {
      # Step 2: Extract key metadata fields
      type = "MetadataExtraction"
      parameters = [
        {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        },
        {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{ timestamp: .timestamp, httpRequest: { clientIp: .httpRequest.clientIp, country: .httpRequest.country, uri: .httpRequest.uri, args: .httpRequest.args, method: .httpRequest.method }, terminatingRuleId: .terminatingRuleId }"
        }
      ]
    },
    {
      # Step 3: Add AWS Glue Data Catalog conversion
      # This allows WAF logs to be queried using Amazon Athena
      type = "DataFormatConversion"
      parameters = [
        {
          parameter_name  = "SchemaConfiguration"
          parameter_value = "{ \"CatalogId\": \"123456789012\", \"DatabaseName\": \"waf_logs\", \"TableName\": \"waf_logs_table\", \"Region\": \"ap-northeast-1\", \"VersionId\": \"LATEST\" }"
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
      # Step 4: Always add a newline after each record
      type = "AppendDelimiterToRecord"
      parameters = [
        {
          parameter_name  = "Delimiter"
          parameter_value = "\\n"
        }
      ]
    }
  ]

  # Enable error logging to CloudWatch
  firehose_enable_error_logging     = true
  firehose_error_log_retention_days = 7
  firehose_error_log_group_name     = "firehose-advanced-processing-errors"
}

output "firehose_delivery_stream_id" {
  value = module.waf_with_advanced_processing.firehose_delivery_stream_id
}

output "log_bucket_id" {
  value = module.waf_with_advanced_processing.log_bucket_id
}
