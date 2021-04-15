resource "random_id" "uniq" {
  byte_length = 4
}

locals {
  lambda_function_name = length(var.lambda_function_name) > 0 ? var.lambda_function_name : "${var.resource_prefix}-function-${random_id.uniq.hex}"
  lambda_role_name     = length(var.lambda_role_name) > 0 ? var.lambda_role_name : "${var.resource_prefix}-lambda-role-${random_id.uniq.hex}"
  event_rule_name      = length(var.event_rule_name) > 0 ? var.event_rule_name : "${var.resource_prefix}-event-rule-${random_id.uniq.hex}"
  bucket_name          = "${var.bucket}-${random_id.uniq.hex}"
}

# Create an event rule for events that cause changes to S3
resource "aws_cloudwatch_event_rule" "default" {
  name        = local.event_rule_name
  description = "A rule to run the lambda daily"
  tags        = var.tags

  schedule_expression = "rate(1 day)"
}

# Set the EventBridge target as the Lambda function
resource "aws_cloudwatch_event_target" "default" {
  rule = aws_cloudwatch_event_rule.default.name
  arn  = aws_lambda_function.s3_export_handler.arn
}

# Create the s3 bucket to store the compliance reports
resource "aws_s3_bucket" "lw-compliance-bucket" {
  bucket = local.bucket_name
  acl    = "private"
}

# Create a Lambda Function for grabbing the compliance report and exporting
resource "aws_lambda_function" "s3_export_handler" {
  function_name = local.lambda_function_name

  filename         = data.archive_file.lambda_app.output_path
  source_code_hash = data.archive_file.lambda_app.output_base64sha256
  timeout = 180
  handler = "lambda_function.lambda_handler"
  runtime = "python3.8"

  layers = [
  aws_lambda_layer_version.laceworksdk_layer.arn
  ]

  role = aws_iam_role.lambda_execution.arn
  tags = var.tags

  environment {
    variables = {
      aws_account_id = var.aws_account_id
      bucket = local.bucket_name
      lw_acct = var.lw_acct
      lw_api_key = var.lw_api_key
      lw_api_secret = var.lw_api_secret
    }
  }
}

# Create a Lambda layer containing the laceworksdk
resource "aws_lambda_layer_version" "laceworksdk_layer" {
  filename   = "${path.module}/lambda/laceworksdk_layer.zip"
  layer_name = "laceworksdk_layer"

  compatible_runtimes = ["python3.8"]
}

# Allow EventBridge to trigger the Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_export_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.default.arn
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_execution" {
  name = local.lambda_role_name
  tags = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


# Allow the Lambda Function to access S3
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lw_s3_export_access"
  role = aws_iam_role.lambda_execution.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "LambdaAccessS3"
    }
  ]
}
EOF
}

# Zip the code for creating the Lambda Function
data "archive_file" "lambda_app" {
  type        = "zip"
  output_path = "${path.module}/tmp/lambda_app.zip"
  source_dir  = "${path.module}/lambda/"
  excludes    = ["tests"]
}
