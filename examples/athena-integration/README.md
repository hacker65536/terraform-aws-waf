# WAF with Athena Integration Example

This example demonstrates how to set up AWS WAF with Kinesis Firehose delivery to S3 and Amazon Athena integration for log analysis. The configuration includes:

1. A Glue database and table for WAF logs
2. A WAF with Firehose delivery stream configured to convert logs to Parquet format
3. An Athena named query for analyzing blocked requests

## Architecture

```
WAF Logs -> Kinesis Firehose -> Data Format Conversion -> S3 (Parquet format) -> Athena Queries
```

## Features Demonstrated

- **Glue Data Catalog Integration**: Creates a Glue database and table schema for WAF logs
- **Parquet Conversion**: Configures Firehose to convert JSON WAF logs to Parquet format
- **Partitioning**: Uses time-based partitioning (year/month/day) for efficient querying
- **Athena Query**: Creates a sample named query for analyzing blocked requests

## Benefits

### Cost Optimization

- **Columnar Storage**: Parquet format reduces the amount of data scanned by Athena queries
- **Partitioning**: Time-based partitioning allows Athena to scan only relevant partitions
- **Compression**: SNAPPY compression reduces storage costs and improves query performance

### Performance

- **Efficient Queries**: Parquet is a columnar format optimized for analytics
- **Reduced Scan Time**: Partitioning and columnar format significantly reduce query execution time
- **Schema Evolution**: Schema can evolve over time as WAF log format changes

### Security Analytics

- **Real-time Insights**: Query logs to identify security patterns and threats
- **Compliance Reporting**: Generate reports for security compliance requirements
- **Threat Intelligence**: Analyze blocked requests to identify potential attack patterns

## Usage

1. Deploy this example using Terraform
2. Access the AWS Athena console
3. Select the `waf_logs_database` database
4. Run the pre-configured named query or create your own queries

## Sample Athena Queries

### Top Blocked IP Addresses

```sql
SELECT
  httprequest.clientip as source_ip,
  COUNT(*) as block_count
FROM
  waf_logs
WHERE
  action = 'BLOCK'
GROUP BY
  httprequest.clientip
ORDER BY
  block_count DESC
LIMIT 10
```

### Geographic Distribution of Blocked Requests

```sql
SELECT
  httprequest.country as country,
  COUNT(*) as request_count
FROM
  waf_logs
WHERE
  action = 'BLOCK'
GROUP BY
  httprequest.country
ORDER BY
  request_count DESC
```

### Top Blocked URLs

```sql
SELECT
  httprequest.uri as uri,
  COUNT(*) as block_count
FROM
  waf_logs
WHERE
  action = 'BLOCK'
GROUP BY
  httprequest.uri
ORDER BY
  block_count DESC
LIMIT 20
```
