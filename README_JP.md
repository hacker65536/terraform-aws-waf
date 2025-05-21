# AWS WAF モジュール（複数のロギングオプション付き）

[![リリース](https://img.shields.io/github/v/release/go-sujun/terraform-aws-waf?style=flat-square)](https://github.com/go-sujun/terraform-aws-waf/releases)
[![ライセンス: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![言語](https://img.shields.io/badge/Languages-EN_|_JA-blue)](./README.md)

このTerraformモジュールは、AWS Web Application Firewall (WAF) を複数のロギング先オプション、柔軟な設定、および強化されたセキュリティ機能で構成します。

*他の言語で読む: [English](README.md), [日本語](README_JP.md)*

## 特徴

- **柔軟なロギングオプション**: 以下の宛先から選択して展開可能:
  - CloudWatch Logs
  - S3 バケット
  - 高度な処理機能を持つKinesis Firehose
- **強化されたセキュリティ**:
  - すべてのロギング先でKMS暗号化をサポート
  - IAM最小権限の原則に基づいた権限管理
  - ログフィールドの編集とフィルタリング機能
- **高度な機能**:
  - 複数のプロセッサを持つFirehose処理パイプライン（レコードの分割、メタデータ抽出、フォーマット変換）
  - リージョンコンプライアンスのためのS3プレフィックスタイムゾーン設定
  - コスト最適化のためのS3バケットのインテリジェントな階層化
  - ParquetフォーマットをサポートするAthena統合
- **完全なモジュール性**:
  - 各ロギングタイプ専用のサブモジュール
  - Terraformで管理およびWAF Charmで管理されるWAFの両方をサポート
  - 簡単に拡張可能なアーキテクチャ

## モジュール構造

このモジュールは、各ロギングタイプ用の個別のサブモジュールを持つモジュラー構造になっています：

- `logging_dist_cloudwatch`: CloudWatchログ設定を処理
- `logging_dist_s3`: S3バケットのログ設定を処理
- `logging_dist_firehose`: Firehoseデリバリーストリーム設定を処理

メインモジュールは、選択されたロギング先に基づいてこれらのサブモジュールを調整します。AWS WAFの制約により、一度に有効にできるロギング先は1つのみです。

## 利用可能な例

このモジュールには、さまざまなユースケースを示すいくつかの例が含まれています：

1. **複数のロギングオプション**: 3種類すべてのロギング先を示します
   - パス: `examples/multiple-logging-options/`
   - 機能: CloudWatch Logs、S3バケット、およびKinesis Firehose

2. **タイムゾーンと処理設定**: タイムゾーン設定と基本的な処理を表示
   - パス: `examples/timezone-test/`
   - 機能: アジア/東京タイムゾーンの設定とメタデータ抽出

3. **高度なFirehose処理**: 包括的なデータ処理パイプラインを示します
   - パス: `examples/advanced-processing/`
   - 機能: レコードの分割、メタデータ抽出、フォーマット変換、およびデータ変換

4. **KMS暗号化**: ログにKMS暗号化を有効にする方法を示します
   - パス: `examples/kms-encryption/`
   - 機能: カスタマーマネージドKMSキー、すべてのログ先の暗号化設定

## ドキュメント

特定の機能に関する詳細情報については、以下のドキュメントを参照してください：

- [アーキテクチャ概要](docs/ARCHITECTURE.md): 高レベルの設計とコンポーネントの相互作用
- [Firehose処理ガイド](docs/firehose-processing.md): 高度なFirehose設定オプション
- [タイムゾーン設定](docs/timezone-config.md): S3プレフィックスのタイムゾーン設定
- [Athena統合](docs/athena-integration.md): AthenaによるWAFログの分析

## ドキュメント生成

このモジュールは[terraform-docs](https://github.com/terraform-docs/terraform-docs)を使用してドキュメントを生成します。

terraform-docsのインストール:
```bash
# macOS
brew install terraform-docs

# Linux
curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
mv terraform-docs /usr/local/bin/
```

ドキュメントの生成:
```bash
# メインモジュールのmarkdownを生成
terraform-docs markdown table --output-file README.md --output-mode inject .

# サブモジュールのmarkdownを生成
terraform-docs markdown table --output-file README.md --output-mode inject ./modules/logging_dist_cloudwatch
terraform-docs markdown table --output-file README.md --output-mode inject ./modules/logging_dist_s3
terraform-docs markdown table --output-file README.md --output-mode inject ./modules/logging_dist_firehose
```

## コード品質の特徴

このモジュールは、Terraformコード品質のためのいくつかのベストプラクティスを実装しています：

1. **バージョン制約**: TerraformとAWSプロバイダの適切なバージョン制約
2. **簡略化されたブール表現**: 適切な場所では比較演算子ではなく直接ブール値を使用
3. **動的リソース作成**: 柔軟なルール設定のためにTerraformの動的ブロックを使用
4. **改善された命名**: 一貫性のある記述的な変数とリソースの命名
5. **パラメータ化**: 設定可能な変数でハードコードされた値を避ける
6. **インテリジェントなストレージ**: コスト最適化のためのオプションのIntelligent-Tiering付きS3バケット
7. **包括的なドキュメント**: すべての変数とリソースの明確な説明
8. **コードモジュール性**: 専用のサブモジュールに分離されたロギング機能
## 高度なFirehose機能

### S3プレフィックスタイムゾーン設定

Firehoseロギングオプションを使用する場合、このモジュールはS3プレフィックスのカスタムタイムゾーン設定をサポートします。これにより、UTCとは異なるタイムゾーンを使用してS3プレフィックスの日付パターンをフォーマットできます。

### 仕組み

モジュールは、Firehoseの拡張S3設定に`custom_time_zone`パラメータを設定します。これにより、S3プレフィックスの`!{timestamp:yyyy-MM-dd}`のような日付パターンの評価方法が変わります。

### 利点

- **リージョンコンプライアンス**: 地域のタイムゾーンに一致するタイムスタンプでログを保存
- **簡略化されたログ分析**: ログ分析時のタイムゾーン変換を回避
- **整理されたストレージ**: ローカル時間に基づく直感的なフォルダ構造を作成

### 使用例

```hcl
module "waf" {
  source = "path/to/module"
  
  # ... 他の設定 ...
  
  # Firehoseロギングを有効にする
  logging_dist_firehose = true
  
  # 東京タイムゾーンでS3プレフィックスを設定
  log_s3_prefix                       = "waf-logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  log_s3_prefix_timezone              = "Asia/Tokyo"  # 東京タイムゾーンで日付をフォーマット
  log_s3_error_output_prefix          = "waf-errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  log_s3_error_output_prefix_timezone = "Asia/Tokyo"  # エラー日付を東京タイムゾーンでフォーマット
}
```

有効なタイムゾーン値は、IANA Time Zone Databaseのフォーマットに従います（例：UTC、America/New_York、Europe/London、Asia/Tokyoなど）。

### Firehoseデータ処理パイプライン

このモジュールは、Firehoseデリバリーストリームの包括的なデータ処理パイプラインの設定をサポートしています。これにより、WAFログをS3に配信する前に変換、フィルタリング、強化、変換することができ、下流の分析と統合がより強力になります。

### 利用可能なプロセッサ

| プロセッサタイプ | 説明 | 一般的なユースケース |
|----------------|-------------|-----------------|
| `AppendDelimiterToRecord` | 各レコードの最後に区切り文字を追加 | ログ処理ツールの適切な改行区切りを確保 |
| `MetadataExtraction` | JSONログから特定のフィールドを抽出 | より高速なクエリのための検索可能なメタデータの作成 |
| `RecordDeAggregation` | 集約されたレコードを分割 | バッチレコードを個別に処理 |
| `Lambda` | AWS Lambda経由でカスタム変換を適用 | 他のプロセッサでカバーされていない複雑な処理ロジック |
| `DataFormatConversion` | データフォーマット間の変換 | Athena統合のためのJSONログをParquetに変換 |

### 処理パイプラインの利点

- **コスト最適化**: 保存前に不要なデータをフィルタリング
- **クエリパフォーマンス**: より高速な分析のためにParquetなどの列形式に変換
- **統合準備完了**: 他のAWSサービスとのシームレスな統合のためのメタデータ抽出
- **スキーマ進化**: 下流のスキーマ要件のためのデータ準備

### 処理パターン例

1. **基本処理**: 適切なレコードフォーマットを確保するための改行区切り文字の追加
2. **分析準備**: Athenaクエリ用のメタデータ抽出とParquetへの変換
3. **データパイプライン取り込み**: Glue ETLやEMR処理のためのデータ準備
4. **リアルタイムモニタリング**: CloudWatchメトリクスやカスタムダッシュボード用の重要フィールドの抽出

### 使用例

```hcl
module "waf" {
  source = "path/to/module"
  
  # ... 他の設定 ...
  
  # Firehoseロギングを有効にする
  logging_dist_firehose = true
  
  # カスタムFirehose処理
  firehose_enable_processing = true
  firehose_processors = [
    {
      # ステップ1: バッチレコードを分割
      type = "RecordDeAggregation"
      parameters = [
        {
          parameter_name  = "SubRecordType"
          parameter_value = "JSON"
        }
      ]
    },
    {
      # ステップ2: WAFログから特定のフィールドを抽出
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
      # ステップ3: 分析のためにParquetに変換（AWS Glue Data Catalogのセットアップが必要）
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
      # ステップ4: 常に各レコードに改行区切り文字を追加
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

完全な例については、このモジュールに含まれる[高度な処理の例](examples/advanced-processing/main.tf)を参照してください。

## KMS暗号化サポート

このモジュールは、すべてのロギング先でWAFログのKMS暗号化をサポートしています：

- **S3バケット**: KMSを使用したサーバーサイド暗号化
- **Firehoseストリーム**: KMSを使用した転送中および保存時の暗号化
- **CloudWatchログ**: KMSを使用した暗号化

### KMS暗号化を有効にする方法

```hcl
module "waf" {
  source = "path/to/module"
  
  # 基本設定
  name   = "example-waf"
  scope  = "REGIONAL"
  
  # ロギング先を有効にする
  logging_dist_s3 = true
  
  # S3/FirehoseのKMS暗号化を有効にする
  log_bucket_keys = true
  kms_key_arn     = "arn:aws:kms:region:account:key/key-id" # オプション
  
  # CloudWatchのKMS暗号化を有効にする（CloudWatchログを使用する場合）
  cloudwatch_enable_kms = true
}
```

## 使用方法

### 単一ロギング先を使用した基本的な使用法

```hcl
module "waf" {
  source = "path/to/module"
  
  name        = "example-waf"
  description = "CloudWatchロギングを有効にした例"
  scope       = "REGIONAL"  # または "CLOUDFRONT"
  
  # 1つのロギング先（CloudWatch、S3、またはFirehose）のみにロギングを有効にする
  # これらのうち1つのみをtrueに設定できます
  logging_dist_cloudwatch = true
  logging_dist_s3         = false
  logging_dist_firehose   = false
  
  # オプションの設定
  log_retention_days = 30  # CloudWatchログの保持
  
  # Firehose固有の設定
  firehose_buffer_interval = 60  # 秒
  firehose_buffer_size     = 5   # MB
  log_s3_prefix            = "waf-logs/"
  log_s3_error_output_prefix = "waf-errors/"
}
```

### CloudWatchログのみ

```hcl
module "waf_cloudwatch" {
  source = "path/to/module"
  
  name        = "example-waf"
  description = "CloudWatchロギングのみを使用した例"
  scope       = "REGIONAL"
  
  # CloudWatchロギングのみを有効にする
  logging_dist_cloudwatch = true
  logging_dist_s3         = false
  logging_dist_firehose   = false
  
  # CloudWatch固有の設定
  log_retention_days = 14
  cloudwatch_log_class = "INFREQUENT_ACCESS"  # アクセスが少ないログに適したクラス
}
```

### S3バケットのみ

```hcl
module "waf_s3" {
  source = "path/to/module"
  
  name        = "example-waf"
  description = "S3ロギングのみを使用した例"
  scope       = "REGIONAL"
  
  # S3ロギングのみを有効にする
  logging_dist_cloudwatch = false
  logging_dist_s3         = true
  logging_dist_firehose   = false
}
```

### Kinesis Firehoseのみ

```hcl
module "waf_firehose" {
  source = "path/to/module"
  
  name        = "example-waf"
  description = "Firehoseロギングのみを使用した例"
  scope       = "REGIONAL"
  
  # Firehoseロギングのみを有効にする
  logging_dist_cloudwatch = false
  logging_dist_s3         = false
  logging_dist_firehose   = true
  
  # 既存のS3バケットをFirehoseに指定することができます
  log_bucket_arn = "arn:aws:s3:::existing-bucket-name"
  
  # Firehoseバッファ設定を構成
  firehose_buffer_interval = 60  # 秒
  firehose_buffer_size     = 5   # MB
}
```

### カスタムタイムゾーンとエラーログを持つKinesis Firehose

```hcl
module "waf_firehose_with_timezone" {
  source = "path/to/module"
  
  name        = "example-waf"
  description = "Firehoseロギングとカスタムタイムゾーンを使用した例"
  scope       = "REGIONAL"
  
  # Firehoseロギングのみを有効にする
  logging_dist_cloudwatch = false
  logging_dist_s3         = false
  logging_dist_firehose   = true
  
  # FirehoseエラーログをCloudWatchに記録
  firehose_enable_error_logging     = true
  firehose_error_log_retention_days = 7
  firehose_error_log_group_name     = "aws-waf-firehose-errors"
  
  # カスタムタイムゾーン設定のS3プレフィックス
  log_s3_prefix                       = "waf-logs/"
  log_s3_prefix_timezone              = "Asia/Tokyo"  # ログに東京タイムゾーンを使用
  log_s3_error_output_prefix          = "waf-errors/"
  log_s3_error_output_prefix_timezone = "Asia/Tokyo"  # エラーログに東京タイムゾーンを使用
}
```

### メタデータ抽出を持つKinesis Firehose

```hcl
module "waf" {
  source = "path/to/module"
  
  # Firehoseロギングを有効にする
  logging_dist_firehose = true
  
  # Firehose処理を有効にする
  firehose_enable_processing = true
  
  # プロセッサを設定
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
## WAF設定のテスト

WAFモジュールを展開した後、選択したロギング先に正しくログが配信されていることを確認するために設定をテストすることが重要です。以下はいくつかのテスト戦略です：

### 1. テストトラフィックの生成

WAFロギングをトリガーするためにアプリケーションにサンプルトラフィックを生成します：

```bash
# WAF評価をトリガーするための簡単なcurlリクエスト
curl -v https://your-application-endpoint.com/test?param1=test

# WAFルールをトリガーする可能性のあるリクエストを送信（例：SQLインジェクションパターン）
curl -v "https://your-application-endpoint.com/test?id=1' OR 1=1--"
```

### 2. CloudWatchログでログを確認

CloudWatchをロギング先として使用している場合：

```bash
# 最近のログイベントを一覧表示（AWS CLI）
aws logs get-log-events \
  --log-group-name "/aws/waf/example-waf" \
  --log-stream-name <log-stream-name> \
  --limit 10
```

### 3. S3でログを確認

S3またはFirehoseをロギング先として使用している場合：

```bash
# ログバケット内のオブジェクトを一覧表示
aws s3 ls s3://your-bucket/waf-logs/

# サンプルログファイルをダウンロードして表示
aws s3 cp s3://your-bucket/waf-logs/<log-file> ./sample-log.gz
gunzip sample-log.gz
cat sample-log
```

### 4. Firehose処理のテスト

Firehose処理を使用する設定の場合：

1. AWS ConsoleでFirehoseデリバリーストリームを確認
2. 処理されたログが期待する形式で表示されることを確認
3. Athena統合を使用している場合、処理されたデータに対してテストクエリを実行：

```sql
-- 処理されたWAFログのAthenaクエリ例
SELECT 
  timestamp,
  httpRequest.clientIp,
  httpRequest.country,
  httpRequest.uri,
  action
FROM waf_logs.waf_logs_table
LIMIT 10;
```