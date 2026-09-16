terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_id" "kms_main_suffix" {
  byte_length = 4
}

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}

resource "random_id" "kms_timestream_suffix" {
  byte_length = 4
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

# KMS Key for general encryption (Lambda env vars, SNS, Timestream)
resource "aws_kms_key" "main" {
  description             = "${var.project_name}-${var.environment}-main-cmk"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowLambdaUse"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowSNSUse"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowTimestreamUse"
        Effect = "Allow"
        Principal = {
          Service = "timestream.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-main-${random_id.kms_main_suffix.hex}"
  target_key_id = aws_kms_key.main.key_id
}

# KMS Key for CloudWatch Logs encryption (RULE 22)
resource "aws_kms_key" "logs" {
  description             = "${var.project_name}-${var.environment}-logs-cmk"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-${var.environment}-compute-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

# IAM Role for Lambda Stream Processor
resource "aws_iam_role" "lambda" {
  name_prefix = "iot-data-pipeli-lambda-processor-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.project_name}-${var.environment}-lambda-processor-policy"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-${var.environment}-processor:*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream",
          "kinesis:ListShards"
        ]
        Resource = data.terraform_remote_state.data.outputs.kinesis_stream_arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = data.terraform_remote_state.data.outputs.dynamodb_table_arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "timestream:WriteRecords",
          "timestream:DescribeDatabase",
          "timestream:DescribeTable"
        ]
        Resource = [
          aws_timestreamwrite_database.main.arn,
          aws_timestreamwrite_table.main.arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.lambda_dlq.arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}

# IAM Role for IoT Topic Rules
resource "aws_iam_role" "iot_rule" {
  name_prefix = "iot-data-pipeline-produ-iot-rule-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "iot.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "iot_rule" {
  name = "${var.project_name}-${var.environment}-iot-rule-policy"
  role = aws_iam_role.iot_rule.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "kinesis:PutRecord"
        Resource = data.terraform_remote_state.data.outputs.kinesis_stream_arn
      },
      {
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${data.terraform_remote_state.data.outputs.s3_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/iot/rule-errors:*"
      }
    ]
  })
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-processor"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# CloudWatch Log Group for IoT Rule Errors
resource "aws_cloudwatch_log_group" "iot_errors" {
  name              = "/aws/iot/rule-errors"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# CloudWatch Log Group for IoT Logging Options
resource "aws_cloudwatch_log_group" "iot_logs" {
  name              = "/aws/iot/logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# IAM Role for IoT Logging Options
resource "aws_iam_role" "iot_logging" {
  name_prefix = "iot-data-pipeline-pr-iot-logging-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "iot.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "iot_logging" {
  name = "${var.project_name}-${var.environment}-iot-logging-policy"
  role = aws_iam_role.iot_logging.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/iot/logs:*"
    }]
  })
}

# IoT Logging Options (account-wide singleton)
resource "aws_iot_logging_options" "main" {
  default_log_level = "ERROR"
  disable_all_logs  = false
  role_arn          = aws_iam_role.iot_logging.arn
}

# IoT Device Policy
resource "aws_iot_policy" "device" {
  name = "${var.project_name}-${var.environment}-device-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["iot:Connect"]
        Resource = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:client/$${iot:Connection.Thing.ThingName}"]
      },
      {
        Effect = "Allow"
        Action = ["iot:Publish"]
        Resource = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/devices/*"]
      },
      {
        Effect = "Allow"
        Action = ["iot:Receive"]
        Resource = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/devices/*"]
      },
      {
        Effect = "Allow"
        Action = ["iot:Subscribe"]
        Resource = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topicfilter/devices/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:GetThingShadow",
          "iot:UpdateThingShadow",
          "iot:DeleteThingShadow"
        ]
        Resource = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:thing/$${iot:Connection.Thing.ThingName}"]
      }
    ]
  })
}

# IoT Topic Rule for Telemetry to Kinesis
resource "aws_iot_topic_rule" "telemetry_to_kinesis" {
  name        = "${var.project_name}-${var.environment}-telemetry-to-kinesis"
  enabled     = true
  sql         = "SELECT *, topic(2) AS device_id, timestamp() AS ingest_ts FROM 'devices/+/telemetry'"
  sql_version = "2016-03-23"

  kinesis {
    role_arn    = aws_iam_role.iot_rule.arn
    stream_name = data.terraform_remote_state.data.outputs.kinesis_stream_name
    partition_key = "$${newuuid()}"
  }

  error_action {
    cloudwatch_logs {
      role_arn       = aws_iam_role.iot_rule.arn
      log_group_name = aws_cloudwatch_log_group.iot_errors.name
    }
  }
}

# IoT Topic Rule for Telemetry to S3 Archive
resource "aws_iot_topic_rule" "telemetry_to_s3" {
  name        = "${var.project_name}-${var.environment}-telemetry-to-s3"
  enabled     = true
  sql         = "SELECT * FROM 'devices/+/archive'"
  sql_version = "2016-03-23"

  s3 {
    role_arn    = aws_iam_role.iot_rule.arn
    bucket_name = data.terraform_remote_state.data.outputs.s3_bucket_id
    key         = "raw/$${topic(2)}/$${timestamp()}.json"
  }

  error_action {
    cloudwatch_logs {
      role_arn       = aws_iam_role.iot_rule.arn
      log_group_name = aws_cloudwatch_log_group.iot_errors.name
    }
  }
}

# Timestream Database
resource "aws_timestreamwrite_database" "main" {
  database_name = "iot_metrics"
  kms_key_id    = aws_kms_key.main.arn
  tags          = var.tags
}

# Timestream Table
resource "aws_timestreamwrite_table" "main" {
  database_name = aws_timestreamwrite_database.main.database_name
  table_name    = "${var.project_name}-${var.environment}-metrics"
  tags          = var.tags

  retention_properties {
    memory_store_retention_period_in_hours  = 24
    magnetic_store_retention_period_in_days = 7
  }
}

# Lambda deployment package (archive_file)
data "archive_file" "processor" {
  type = "zip"
  source_content = <<-PY
    import json
    import os
    import boto3
    import base64

    dynamodb = boto3.resource('dynamodb')
    timestream = boto3.client('timestream-write')

    DYNAMODB_TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME')
    TIMESTREAM_DATABASE_NAME = os.environ.get('TIMESTREAM_DATABASE_NAME')
    TIMESTREAM_TABLE_NAME = os.environ.get('TIMESTREAM_TABLE_NAME')

    def handler(event, context):
        dynamodb_table = dynamodb.Table(DYNAMODB_TABLE_NAME)

        records = []
        for record in event['Records']:
            # Kinesis data is base64 encoded
            payload = base64.b64decode(record['kinesis']['data']).decode('utf-8')
            data = json.loads(payload)
            records.append(data)

            # Example: Update DynamoDB for current state/aggregates
            device_id = data.get('device_id')
            if device_id:
                dynamodb_table.put_item(
                    Item={
                        'device_id': device_id,
                        'last_reading': json.dumps(data),
                        'timestamp': data.get('ingest_ts')
                    }
                )

            # Example: Write to Timestream for time-series metrics
            if TIMESTREAM_DATABASE_NAME and TIMESTREAM_TABLE_NAME:
                dimensions = [{'Name': 'device_id', 'Value': data.get('device_id', 'unknown')}]
                
                # Assuming 'temperature' and 'humidity' are example metrics
                metrics = []
                if 'temperature' in data:
                    metrics.append({
                        'MeasureName': 'temperature',
                        'MeasureValue': str(data['temperature']),
                        'MeasureValueType': 'DOUBLE',
                        'Dimensions': dimensions
                    })
                if 'humidity' in data:
                    metrics.append({
                        'MeasureName': 'humidity',
                        'MeasureValue': str(data['humidity']),
                        'MeasureValueType': 'DOUBLE',
                        'Dimensions': dimensions
                    })

                if metrics:
                    try:
                        timestream.write_records(
                            DatabaseName=TIMESTREAM_DATABASE_NAME,
                            TableName=TIMESTREAM_TABLE_NAME,
                            Records=metrics,
                            CommonAttributes={
                                'Time': str(data.get('ingest_ts')),
                                'TimeUnit': 'MILLISECONDS'
                            }
                        )
                    except Exception as e:
                        print(f"Error writing to Timestream: {e}")

        print(f"Processed {len(records)} records.")
        return {"statusCode": 200, "body": json.dumps("ok")}
  PY
  source_content_filename = "processor.py"
  output_path             = "${path.module}/build/processor.zip"
}

# SQS Dead Letter Queue for Lambda
resource "aws_sqs_queue" "lambda_dlq" {
  name                      = "${var.project_name}-${var.environment}-lambda-dlq"
  message_retention_seconds = 1209600 # 14 days
  kms_master_key_id         = aws_kms_key.main.arn
  tags                      = var.tags
}

resource "aws_sqs_queue_policy" "lambda_dlq" {
  queue_url = aws_sqs_queue.lambda_dlq.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.lambda_dlq.arn
      Condition = {
        ArnLike = {
          "aws:SourceArn" = aws_lambda_function.processor.arn
        }
      }
    }]
  })
}

# Lambda Stream Processor Function
resource "aws_lambda_function" "processor" {
  function_name    = "${var.project_name}-${var.environment}-processor"
  role             = aws_iam_role.lambda.arn
  handler          = "processor.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.processor.output_path
  source_code_hash = data.archive_file.processor.output_base64sha256
  timeout          = 60
  memory_size      = 512

  tracing_config {
    mode = "Active"
  }

  reserved_concurrent_executions = 100

  kms_key_arn = aws_kms_key.main.arn # For environment variables encryption

  environment {
    variables = {
      DYNAMODB_TABLE_NAME    = data.terraform_remote_state.data.outputs.dynamodb_table_name
      TIMESTREAM_DATABASE_NAME = aws_timestreamwrite_database.main.database_name
      TIMESTREAM_TABLE_NAME  = aws_timestreamwrite_table.main.table_name
    }
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  vpc_config {
    subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  }

  tags = var.tags
}

# Lambda Event Source Mapping for Kinesis Stream
resource "aws_lambda_event_source_mapping" "kinesis" {
  event_source_arn = data.terraform_remote_state.data.outputs.kinesis_stream_arn
  function_name    = aws_lambda_function.processor.arn
  starting_position = "LATEST"
  batch_size       = 100
  enabled          = true
}

# SNS Topic for CloudWatch Alarms
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.main.arn
  tags              = var.tags
}

resource "aws_sns_topic_policy" "alarms" {
  arn = aws_sns_topic.alarms.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudWatchAlarms"
      Effect    = "Allow"
      Principal = { Service = "cloudwatch.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.alarms.arn
    }]
  })
}

# CloudWatch Alarm: Lambda Error Rate
resource "aws_cloudwatch_metric_alarm" "lambda_error_rate" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0 # Any errors
  alarm_description   = "Alarm when Lambda function experiences errors"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    FunctionName = aws_lambda_function.processor.function_name
  }
  tags = var.tags
}

# CloudWatch Alarm: Kinesis Iterator Age
resource "aws_cloudwatch_metric_alarm" "kinesis_iterator_age" {
  alarm_name          = "${var.project_name}-${var.environment}-kinesis-iterator-age"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "IteratorAgeMilliseconds"
  namespace           = "AWS/Kinesis"
  period              = 300
  statistic           = "Maximum"
  threshold           = 60000 # 1 minute
  alarm_description   = "Alarm when Kinesis stream iterator age is high"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    StreamName = data.terraform_remote_state.data.outputs.kinesis_stream_name
  }
  tags = var.tags
}

# CloudWatch Alarm: DynamoDB Throttled Events
resource "aws_cloudwatch_metric_alarm" "dynamodb_throttled_events" {
  alarm_name          = "${var.project_name}-${var.environment}-dynamodb-throttled-events"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 0 # Any throttled requests
  alarm_description   = "Alarm when DynamoDB table experiences throttled requests"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    TableName = data.terraform_remote_state.data.outputs.dynamodb_table_name
  }
  tags = var.tags
}

# CloudWatch Alarm: Timestream Write Errors
resource "aws_cloudwatch_metric_alarm" "timestream_write_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-timestream-write-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "WriteRecordsErrors"
  namespace           = "AWS/Timestream"
  period              = 300
  statistic           = "Sum"
  threshold           = 0 # Any write errors
  alarm_description   = "Alarm when Timestream table experiences write errors"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DatabaseName = aws_timestreamwrite_database.main.database_name
    TableName    = aws_timestreamwrite_table.main.table_name
  }
  tags = var.tags
}
