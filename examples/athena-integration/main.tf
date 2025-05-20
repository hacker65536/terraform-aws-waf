provider "aws" {
  region = "us-east-1"
}

#--------------------------------------------------------------
# Example: WAF with Firehose and Athena Integration
#--------------------------------------------------------------

# First, create the Glue database and table for WAF logs
resource "aws_glue_catalog_database" "waf_logs_db" {
  name        = "waf_logs_database"
  description = "Database for WAF logs"
}

# Create a Glue table for WAF logs in Parquet format
resource "aws_glue_catalog_table" "waf_logs_table" {
  name          = "waf_logs"
  database_name = aws_glue_catalog_database.waf_logs_db.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = "s3://${module.waf_with_athena.log_bucket_id}/waf-logs/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "ParquetHiveSerDe"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    # Define the schema for WAF logs
    columns {
      name = "timestamp"
      type = "timestamp"
    }
    columns {
      name = "formatversion"
      type = "int"
    }
    columns {
      name = "webaclid"
      type = "string"
    }
    columns {
      name = "terminatingruleid"
      type = "string"
    }
    columns {
      name = "terminatingruletype"
      type = "string"
    }
    columns {
      name = "action"
      type = "string"
    }
    columns {
      name = "httpsourcename"
      type = "string"
    }
    columns {
      name = "httpsourceid"
      type = "string"
    }
    columns {
      name = "rulegrouplist"
      type = "array<struct<ruleGroupId:string,terminatingRule:struct<ruleId:string,action:string,ruleMatchDetails:array<struct<conditionType:string>>>,nonTerminatingMatchingRules:array<struct<ruleId:string,action:string,overriddenAction:string,ruleMatchDetails:array<struct<conditionType:string>>>>,excludedRules:array<struct<ruleId:string,exclusionType:string>>>>"
    }
    columns {
      name = "ratebasedrulelist"
      type = "array<struct<rateBasedRuleId:string,limitKey:string,maxRateAllowed:int>>"
    }
    columns {
      name = "nonterminatingmatchingrules"
      type = "array<struct<ruleId:string,action:string,ruleMatchDetails:array<struct<conditionType:string>>>>"
    }
    columns {
      name = "httprequest"
      type = "struct<clientIp:string,country:string,headers:array<struct<name:string,value:string>>,uri:string,args:string,httpVersion:string,httpMethod:string,requestId:string>"
    }
  }
}

# Now create the WAF with Firehose configured to deliver to Athena
module "waf_with_athena" {
  source = "../../"

  name        = "athena-integration-waf"
  description = "WAF with Athena integration via Firehose"
  scope       = "REGIONAL"

  # Enable Firehose logging only
  logging_dist_cloudwatch = false
  logging_dist_s3         = false
  logging_dist_firehose   = true

  # Basic Firehose settings
  firehose_buffer_interval = 60
  firehose_buffer_size     = 128

  # S3 prefix with year/month/day partitioning for Athena
  log_s3_prefix              = "waf-logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  log_s3_error_output_prefix = "waf-errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

  # Enable processing with data conversion
  firehose_enable_processing = true
  firehose_processors = [
    {
      # Convert to Parquet format for Athena queries
      type = "DataFormatConversion"
      parameters = [
        {
          parameter_name = "SchemaConfiguration"
          parameter_value = jsonencode({
            CatalogId    = data.aws_caller_identity.current.account_id
            DatabaseName = aws_glue_catalog_database.waf_logs_db.name
            TableName    = aws_glue_catalog_table.waf_logs_table.name
            Region       = data.aws_region.current.name
            VersionId    = "LATEST"
          })
        },
        {
          parameter_name = "InputFormatConfiguration"
          parameter_value = jsonencode({
            Deserializer = {
              OpenXJsonSerDe = {
                CaseInsensitive = true
              }
            }
          })
        },
        {
          parameter_name = "OutputFormatConfiguration"
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

  # Enable error logging to CloudWatch
  firehose_enable_error_logging     = true
  firehose_error_log_retention_days = 7
}

# Example Athena query
resource "aws_athena_named_query" "waf_blocked_requests" {
  name        = "WAF-BlockedRequests"
  description = "Query to find blocked requests in WAF logs"
  database    = aws_glue_catalog_database.waf_logs_db.name
  query       = <<-EOF
    SELECT
      from_unixtime(timestamp/1000) as request_time,
      httprequest.clientip as source_ip,
      httprequest.country as country,
      httprequest.httpmethod as method,
      httprequest.uri as uri,
      action as waf_action,
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

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

output "firehose_delivery_stream_id" {
  value = module.waf_with_athena.firehose_delivery_stream_id
}

output "log_bucket_id" {
  value = module.waf_with_athena.log_bucket_id
}

output "glue_database_name" {
  value = aws_glue_catalog_database.waf_logs_db.name
}

output "glue_table_name" {
  value = aws_glue_catalog_table.waf_logs_table.name
}

output "athena_query_name" {
  value = aws_athena_named_query.waf_blocked_requests.name
}
