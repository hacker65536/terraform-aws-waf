# AWS WAF Module Architecture

This document provides an overview of the AWS WAF module architecture and workflow.

## Architectural Overview

```
┌──────────────┐     ┌─────────────────┐
│              │     │                 │
│    AWS WAF   │────▶│  WAF Web ACL    │
│              │     │                 │
└──────────────┘     └────────┬────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Logging Config │
                    └────────┬────────┘
                              │
                  ┌──────────┴───────────┐
                  │                      │
        ┌─────────▼──────┐     ┌─────────▼──────┐     ┌─────────▼──────┐
        │               │     │                │     │                │
        │  CloudWatch   │     │  Kinesis       │     │  S3 Bucket     │
        │  Logs         │     │  Firehose      │     │  Direct        │
        │               │     │                │     │                │
        └───────────────┘     └────────┬───────┘     └────────────────┘
                                       │
                                       │
                           ┌───────────▼──────────┐
                           │                      │
                           │  Processing Pipeline  │
                           │  ┌────────────────┐  │
                           │  │Record Deagg.   │  │
                           │  ├────────────────┤  │
                           │  │Metadata Extract│  │
                           │  ├────────────────┤  │
                           │  │Format Convert. │  │
                           │  ├────────────────┤  │
                           │  │Lambda Transform│  │
                           │  └────────────────┘  │
                           └───────────┬──────────┘
                                       │
                                       │
                            ┌──────────▼─────────┐
                            │                    │
                            │  S3 Bucket with    │
                            │  Time-based        │
                            │  Partitioning      │
                            │                    │
                            └──────────┬─────────┘
                                       │
                                       │
                            ┌──────────▼─────────┐
                            │                    │
                            │  Analytics         │
                            │  ┌──────────────┐  │
                            │  │AWS Athena    │  │
                            │  ├──────────────┤  │
                            │  │AWS QuickSight│  │
                            │  ├──────────────┤  │
                            │  │Amazon OpenS. │  │
                            │  └──────────────┘  │
                            │                    │
                            └────────────────────┘
```

## Key Components

### 1. AWS WAF Web ACL

Creates a Web Application Firewall that protects your web applications from common web exploits.

### 2. Logging Configuration

The module supports three different logging destinations:

- **CloudWatch Logs**: For real-time monitoring and alerts
- **S3 Direct**: Simple storage of raw logs 
- **Kinesis Firehose**: Advanced processing and delivery

### 3. Firehose Processing Pipeline

When using Firehose, the module supports a comprehensive data processing pipeline:

1. **Record Deaggregation**: Splits aggregated records
2. **Metadata Extraction**: Extracts specific fields from JSON logs
3. **Format Conversion**: Converts between data formats (e.g., JSON to Parquet)
4. **Lambda Transformation**: Applies custom transformations via AWS Lambda

### 4. S3 Storage with Time-based Partitioning

The module supports configurable time-based partitioning for S3:

- Year/month/day partitioning
- Custom timezone support
- Intelligent-Tiering for cost optimization

### 5. Analytics Integration

The processed logs can be easily integrated with various AWS analytics services:

- **Amazon Athena**: SQL-based querying
- **Amazon QuickSight**: Visualization and dashboards
- **Amazon OpenSearch**: Full-text search and analytics

## Data Flow

1. Web traffic passes through the AWS WAF Web ACL
2. WAF logs are sent to the configured logging destination
3. If using Firehose, logs go through the processing pipeline
4. Processed logs are stored in S3 with time-based partitioning
5. Analytics services can query the processed logs

## Logging Destination Selection

Due to AWS WAF constraints, only one logging destination can be enabled at a time. This is enforced by validation in the module code.
