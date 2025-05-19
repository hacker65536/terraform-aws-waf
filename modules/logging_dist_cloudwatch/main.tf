resource "aws_cloudwatch_log_group" "log_group" {
  name              = "aws-waf-logs-${var.name}"
  retention_in_days = var.log_retention_days
  log_group_class   = var.log_class
}

data "aws_iam_policy_document" "log_resource_policy" {
  version = "2012-10-17"
  statement {
    sid    = "AllowWAFLogging"
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.log_group.arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(var.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "waf_logging_policy" {
  policy_name     = "waf-logging-policy-${var.name}"
  policy_document = data.aws_iam_policy_document.log_resource_policy.json
}
