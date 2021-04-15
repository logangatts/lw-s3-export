# S3 Compliance Report Export

## Description

A Terraform Module to implement exporting compliance reports from Lacework to an S3 bucket using Lambda.

This module will implement a CloudWatch rule on a daily schedule which triggers a Lambda function. The Lambda function will use the LaceworkSDK as a Lambda layer to grab the latest AWS compliance report and place it in the created S3 bucket.

## Inputs

| Name                 | Description                                                                  | Type          | Default          |
| -------------------- | ---------------------------------------------------------------------------- | ------------- | ---------------- |
| bucket               | The desired name of the S3 bucket that will hold the compliance reports      | `string`      | "lacework-compliance-reports" |
| event_rule_name      | The desired name of the CloudWatch event rule                                | `string`      | ""               |
| lambda_function_name | The desired name of the S3 remediation lambda function                       | `string`      | ""               |
| lambda_role_name     | The desired IAM role name for the S3 remediation lambda function             | `string`      | ""               |
| lambda_tracing_mode  | The desired tracing mode for the lambda function ("Active" or "PassThrough") | `string`      | "PassThrough"    |
| resource_prefix      | The name prefix to use for resources provisioned by the module               | `string`      | "s3-remediation" |
| tags                 | A map of tags to be assigned to created resources                            | `map(string)` | `{}`             |

## Outputs

| Name                | Description                                         |
| ------------------- | --------------------------------------------------- |
| cloudwatch_rule_arn | ARN of the created CloudWatch rule                  |
| lambda_function_arn | ARN of the created Lambda function                  |
| lambda_role_arn     | ARN of the created IAM Role for the Lambda function |
