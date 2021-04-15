variable "bucket" {
  type        = string
  default     = "lacework-compliance-reports"
  description = "The desired name of the bucket for the lw compliance reports"
}

variable "event_rule_name" {
  type        = string
  default     = "lw-daily-scheduled"
  description = "The desired name of the CloudWatch event rule"
}

variable "lambda_function_name" {
  type        = string
  default     = "lw-s3-export-function"
  description = "The desired name of the S3 export lambda function"
}

variable "lambda_role_name" {
  type        = string
  default     = "lw-s3-export-lambda"
  description = "The desired IAM role name for the S3 export lambda function"
}

variable "resource_prefix" {
  type        = string
  default     = "s3-export"
  description = "The name prefix to use for resources provisioned by the module"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to be assigned to created resources"
  default     = {}
}

variable "aws_account_id" {
  type        = string
  description = "The AWS account ID of the desired compliance report to export"
}

variable "lw_acct" {
  type        = string
  description = "The Lacework account name from the API key file - Do not include the `.lacework.net`"
}

variable "lw_api_key" {
  type        = string
  description = "The Lacework keyID from the API key file"
}

variable "lw_api_secret" {
  type        = string
  description = "The Lacework secret from the API key file"
}
