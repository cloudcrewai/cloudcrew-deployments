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

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

# KMS Key for this phase

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
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-${var.environment}-compute-logs"
  target_key_id = aws_kms_key.logs.key_id
}

resource "aws_kms_key" "main" {
  description             = "${var.project_name}-${var.environment}-compute-cmk"
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
      },
      {
        Sid    = "AllowS3Use"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
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
        Sid    = "AllowSQSUse"
        Effect = "Allow"
        Principal = {
          Service = "sqs.amazonaws.com"
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
        Sid    = "AllowSNSPublish"
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
      }
    ]
  })
  tags = var.tags
}

resource "random_id" "kms_main_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-compute-${random_id.kms_main_suffix.hex}"
  target_key_id = aws_kms_key.main.key_id
}

# CloudWatch Log Group for general application logs
resource "aws_cloudwatch_log_group" "main" {
  name              = "/${var.project_name}/${var.environment}/app"
  retention_in_days = var.log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

# CloudWatch Log Group for IoT rule errors
resource "aws_cloudwatch_log_group" "iot_errors" {
  name              = "/aws/iot/rule-errors"
  retention_in_days = var.log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

# CloudWatch Log Group for VPC Flow Logs
# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/${var.project_name}/cloudtrail"
  retention_in_days = var.audit_log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

# CloudWatch Log Group for AWS Config
resource "aws_cloudwatch_log_group" "config" {
  name              = "/${var.project_name}/config"
  retention_in_days = var.audit_log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_logs" {
  name_prefix = "iot-data-pipeline-prod-flow-logs-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "vpc-flow-logs.amazonaws.com" } }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.project_name}-${var.environment}-flow-logs-policy"
  role = aws_iam_role.flow_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/${var.project_name}/*"
      },
      {
        Action   = ["logs:DescribeLogGroups"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/${var.project_name}/*"
      }
    ]
  })
}

# VPC Flow Logs
# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  tags        = var.tags

  ingress {
    description     = "Allow all traffic from VPC CIDR"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  }

  egress {
    description = "All traffic within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  }
}

# VPC Interface Endpoint for Kinesis
resource "aws_vpc_endpoint" "kinesis" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.kinesis-streams"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags              = var.tags
}

# VPC Gateway Endpoint for DynamoDB
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.terraform_remote_state.networking.outputs.private_route_table_ids
  tags              = var.tags
}

# VPC Interface Endpoint for Secrets Manager
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags              = var.tags
}

# VPC Interface Endpoint for KMS
resource "aws_vpc_endpoint" "kms" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags              = var.tags
}

# VPC Interface Endpoint for CloudWatch Logs
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags              = var.tags
}

# VPC Interface Endpoint for Timestream Write
resource "aws_vpc_endpoint" "timestream_write" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.timestream-write"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags              = var.tags
}

# VPC Interface Endpoint for Timestream Query
resource "aws_vpc_endpoint" "timestream_query" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.timestream-query"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags              = var.tags
}

# Timestream Database
resource "aws_timestreamwrite_database" "iot_metrics" {
  database_name = var.timestream_database_name
  kms_key_id    = aws_kms_key.main.arn
  tags          = var.tags
}

# Timestream Table
resource "aws_timestreamwrite_table" "device_telemetry" {
  database_name = aws_timestreamwrite_database.iot_metrics.database_name
  table_name    = var.timestream_table_name
  retention_properties {
    memory_store_retention_period_in_hours  = var.timestream_memory_retention_hours
    magnetic_store_retention_period_in_days = var.timestream_magnetic_retention_days
  }
  tags = var.tags
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

resource "aws_iam_role_policy" "iot_rule_kinesis" {
  name = "${var.project_name}-${var.environment}-iot-rule-kinesis-policy"
  role = aws_iam_role.iot_rule.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["kinesis:PutRecord"]
        Resource = data.terraform_remote_state.data.outputs.kinesis_stream_arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${data.terraform_remote_state.data.outputs.s3_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = aws_cloudwatch_log_group.iot_errors.arn
      },
      {
        Effect   = "Allow"
        Action   = ["timestream:WriteRecords"]
        Resource = aws_timestreamwrite_table.device_telemetry.arn
      },
      {
        Effect   = "Allow"
        Action   = ["timestream:DescribeEndpoints"]
        Resource = "*"
      }
    ]
  })
}

# IoT Policy for devices
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
        Resource = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/devices/$${iot:Connection.Thing.ThingName}/telemetry"]
      },
      {
        Effect = "Allow"
        Action = ["iot:Receive"]
        Resource = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/devices/$${iot:Connection.Thing.ThingName}/commands"]
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

# IoT Topic Rule: Telemetry to Kinesis
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
  tags = var.tags
}

# IoT Topic Rule: Telemetry to S3 Archive
resource "aws_iot_topic_rule" "telemetry_to_s3" {
  name        = "${var.project_name}-${var.environment}-telemetry-to-s3"
  enabled     = true
  sql         = "SELECT * FROM 'devices/+/telemetry'"
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
  tags = var.tags
}

# IoT Topic Rule: Telemetry to Timestream
resource "aws_iot_topic_rule" "telemetry_to_timestream" {
  name        = "${var.project_name}-${var.environment}-telemetry-to-timestream"
  enabled     = true
  sql         = "SELECT * FROM 'devices/+/telemetry'"
  sql_version = "2016-03-23"

  timestream {
    role_arn      = aws_iam_role.iot_rule.arn
    database_name = aws_timestreamwrite_database.iot_metrics.database_name
    table_name    = aws_timestreamwrite_table.device_telemetry.table_name
    dimension {
      name  = "device_id"
      value = "$${topic(2)}"
    }
    timestamp {
      value = "$${timestamp()}"
      unit  = "MILLISECONDS"
    }
  }

  error_action {
    cloudwatch_logs {
      role_arn       = aws_iam_role.iot_rule.arn
      log_group_name = aws_cloudwatch_log_group.iot_errors.name
    }
  }
  tags = var.tags
}

# IAM Role for IoT Logging
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
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
      Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/iot/*"
    }]
  })
}

# IoT Logging Options (account-wide singleton)
resource "aws_iot_logging_options" "main" {
  default_log_level = "ERROR"
  role_arn          = aws_iam_role.iot_logging.arn
  disable_all_logs  = false
}

# Lambda Processor
data "archive_file" "processor" {
  type = "zip"
  source_content = <<-PY
    import json
    import os
    import boto3

    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ.get('DYNAMODB_TABLE_NAME')
    dynamodb_table = dynamodb.Table(table_name)

    def handler(event, context):
        for record in event['Records']:
            payload = json.loads(record['kinesis']['data'])
            device_id = payload.get('device_id')
            ingest_ts = payload.get('ingest_ts')
            
            if device_id and ingest_ts:
                try:
                    dynamodb_table.put_item(
                        Item={
                            'device_id': device_id,
                            'ingest_ts': ingest_ts,
                            'data': payload
                        }
                    )
                    print(f"Successfully wrote item for device {device_id} at {ingest_ts}")
                except Exception as e:
                    print(f"Error writing to DynamoDB for device {device_id}: {e}")
            else:
                print(f"Skipping record due to missing device_id or ingest_ts: {payload}")
        return {"statusCode": 200, "body": json.dumps("Processed Kinesis records")}
  PY
  source_content_filename = "processor.py"
  output_path             = "${path.module}/build/processor.zip"
}

resource "aws_iam_role" "lambda_processor" {
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

resource "aws_iam_role_policy_attachment" "lambda_processor_basic_execution" {
  role       = aws_iam_role.lambda_processor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_processor_vpc_access" {
  role       = aws_iam_role.lambda_processor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_processor_custom" {
  name = "${var.project_name}-${var.environment}-lambda-processor-custom-policy"
  role = aws_iam_role.lambda_processor.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["kinesis:GetRecords", "kinesis:GetShardIterator", "kinesis:DescribeStream", "kinesis:ListShards"]
        Resource = data.terraform_remote_state.data.outputs.kinesis_stream_arn
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = data.terraform_remote_state.data.outputs.dynamodb_table_arn
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.lambda_dlq.arn
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}

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
    }]
  })
}

resource "aws_lambda_function" "processor" {
  function_name    = "${var.project_name}-${var.environment}-kinesis-processor"
  role             = aws_iam_role.lambda_processor.arn
  handler          = "processor.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.processor.output_path
  source_code_hash = data.archive_file.processor.output_base64sha256
  timeout          = var.lambda_processor_timeout
  memory_size      = var.lambda_processor_memory_mb
  kms_key_arn      = aws_kms_key.main.arn # For environment variables encryption

  vpc_config {
    subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  }

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = data.terraform_remote_state.data.outputs.dynamodb_table_name
    }
  }

  tracing_config {
    mode = "Active"
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  reserved_concurrent_executions = var.lambda_processor_reserved_concurrency
  tags                           = var.tags
}

resource "aws_lambda_event_source_mapping" "kinesis_to_lambda" {
  event_source_arn = data.terraform_remote_state.data.outputs.kinesis_stream_arn
  function_name    = aws_lambda_function.processor.arn
  starting_position = "LATEST"
  batch_size        = 100
  enabled           = true
}

# SNS Topic for Alarms
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

# CloudWatch Alarms for Lambda Processor
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-processor-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Lambda processor function has errors"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    FunctionName = aws_lambda_function.processor.function_name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-processor-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Lambda processor function is throttled"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    FunctionName = aws_lambda_function.processor.function_name
  }
  tags = var.tags
}

# CloudWatch Alarm for Kinesis Iterator Age
resource "aws_cloudwatch_metric_alarm" "kinesis_iterator_age" {
  alarm_name          = "${var.project_name}-${var.environment}-kinesis-iterator-age"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "IteratorAgeMilliseconds"
  namespace           = "AWS/Kinesis"
  period              = 300
  statistic           = "Maximum"
  threshold           = 60000 # 1 minute
  alarm_description   = "Kinesis stream iterator age is too high, indicating processing lag"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    StreamName = data.terraform_remote_state.data.outputs.kinesis_stream_name
  }
  tags = var.tags
}

# CloudWatch Alarm for Timestream Write Errors
resource "aws_cloudwatch_metric_alarm" "timestream_write_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-timestream-write-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "WriteRecordsErrors"
  namespace           = "AWS/Timestream"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Timestream write records errors detected"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DatabaseName = aws_timestreamwrite_database.iot_metrics.database_name
    TableName    = aws_timestreamwrite_table.device_telemetry.table_name
  }
  tags = var.tags
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "iot_monitoring" {
  dashboard_name = "${var.project_name}-${var.environment}-iot-monitoring"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          region = var.region
          metrics = [
            ["AWS/IoT", "MessagesPublished", "RuleName", aws_iot_topic_rule.telemetry_to_kinesis.name],
            ["AWS/IoT", "MessagesPublished", "RuleName", aws_iot_topic_rule.telemetry_to_s3.name],
            ["AWS/IoT", "MessagesPublished", "RuleName", aws_iot_topic_rule.telemetry_to_timestream.name]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "IoT Messages Published"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          region = var.region
          metrics = [
            ["AWS/Kinesis", "IncomingBytes", "StreamName", data.terraform_remote_state.data.outputs.kinesis_stream_name],
            ["AWS/Kinesis", "IncomingRecords", "StreamName", data.terraform_remote_state.data.outputs.kinesis_stream_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "Kinesis Incoming Data"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          region = var.region
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.processor.function_name],
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.processor.function_name],
            ["AWS/Lambda", "Throttles", "FunctionName", aws_lambda_function.processor.function_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "Lambda Processor Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          region = var.region
          metrics = [
            ["AWS/Timestream", "WriteRecordsErrors", "DatabaseName", aws_timestreamwrite_database.iot_metrics.database_name, "TableName", aws_timestreamwrite_table.device_telemetry.table_name],
            ["AWS/Timestream", "RecordsIngested", "DatabaseName", aws_timestreamwrite_database.iot_metrics.database_name, "TableName", aws_timestreamwrite_table.device_telemetry.table_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "Timestream Write Metrics"
        }
      }
    ]
  })
}

# CloudTrail S3 Bucket
resource "random_id" "cloudtrail_bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "iot-d-cloudtrail-logs-${random_id.cloudtrail_bucket_suffix.hex}"
  force_destroy = false # Production bucket
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.cloudtrail_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudTrailLogging"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# IAM Role for CloudTrail
resource "aws_iam_role" "cloudtrail" {
  name_prefix = "iot-data-pipeline-pro-cloudtrail-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "cloudtrail" {
  name = "${var.project_name}-${var.environment}-cloudtrail-policy"
  role = aws_iam_role.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetBucketAcl"]
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Effect   = "Allow"
        Action   = ["logs:PutLogEvents", "logs:CreateLogStream"]
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

# SNS Topic for CloudTrail Notifications
resource "aws_sns_topic" "cloudtrail_notifications" {
  name              = "${var.project_name}-${var.environment}-cloudtrail-notifications"
  kms_master_key_id = aws_kms_key.main.arn
  tags              = var.tags
}

resource "aws_sns_topic_policy" "cloudtrail_notifications" {
  arn = aws_sns_topic.cloudtrail_notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudTrailPublish"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.cloudtrail_notifications.arn
    }]
  })
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  sns_topic_name                = aws_sns_topic.cloudtrail_notifications.name
  tags                          = var.tags
}

# CloudWatch Metric Filters for CloudTrail
resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "${var.project_name}-${var.environment}-root-login-filter"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "RootLoginCount"
    namespace     = "${var.project_name}/CloudTrail"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_login" {
  alarm_name          = "${var.project_name}-${var.environment}-root-login-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.root_login.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.root_login.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for root account login"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "mfa_disabled" {
  name           = "${var.project_name}-${var.environment}-mfa-disabled-filter"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed != \"Yes\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "MfaDisabledLoginCount"
    namespace     = "${var.project_name}/CloudTrail"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "mfa_disabled" {
  alarm_name          = "${var.project_name}-${var.environment}-mfa-disabled-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.mfa_disabled.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.mfa_disabled.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for console login without MFA"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "${var.project_name}-${var.environment}-unauthorized-api-calls-filter"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "UnauthorizedApiCallsCount"
    namespace     = "${var.project_name}/CloudTrail"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "${var.project_name}-${var.environment}-unauthorized-api-calls-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for unauthorized API calls"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

# GuardDuty Detector
resource "aws_guardduty_detector" "main" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags                         = var.tags
}

resource "aws_guardduty_detector_feature" "s3_data_events" {
  detector_id = aws_guardduty_detector.main.id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

# AWS Config S3 Bucket
resource "random_id" "config_bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "config_bucket" {
  bucket        = "iot-data-pi-config-bucket-${random_id.config_bucket_suffix.hex}"
  force_destroy = false # Production bucket
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "config_bucket" {
  bucket                  = aws_s3_bucket.config_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config_bucket.arn}/AWSConfig/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# SNS Topic for AWS Config Notifications
resource "aws_sns_topic" "config_notifications" {
  name              = "${var.project_name}-${var.environment}-config-notifications"
  kms_master_key_id = aws_kms_key.main.arn
  tags              = var.tags
}

resource "aws_sns_topic_policy" "config_notifications" {
  arn = aws_sns_topic.config_notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowConfigPublish"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.config_notifications.arn
    }]
  })
}

# IAM Role for AWS Config
resource "aws_iam_role" "config" {
  name_prefix = "iot-data-pipeline-product-config-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "config" {
  name = "${var.project_name}-${var.environment}-config-policy"
  role = aws_iam_role.config.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetBucketAcl"]
        Resource = "${aws_s3_bucket.config_bucket.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetBucketPolicy"]
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.config_notifications.arn
      },
      {
        Effect   = "Allow"
        Action   = ["logs:PutLogEvents", "logs:CreateLogStream"]
        Resource = aws_cloudwatch_log_group.config.arn
      }
    ]
  })
}

# AWS Config Configuration Recorder
resource "aws_config_configuration_recorder" "main" {
  name     = "${var.project_name}-${var.environment}-recorder"
  role_arn = aws_iam_role.config.arn
  recording_group {
    all_supported             = true
    include_global_resource_types = true
  }
}

# AWS Config Delivery Channel
resource "aws_config_delivery_channel" "main" {
  name          = "${var.project_name}-${var.environment}-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.id
  sns_topic_arn = aws_sns_topic.config_notifications.arn
}

# AWS Config Configuration Recorder Status
resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}

# AWS Config Managed Rules
resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name        = "${var.project_name}-${var.environment}-s3-public-read-prohibited"
  description = "Checks if S3 buckets are publicly readable."
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name        = "${var.project_name}-${var.environment}-encrypted-volumes"
  description = "Checks whether EBS volumes are encrypted."
  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  name        = "${var.project_name}-${var.environment}-iam-root-access-key-check"
  description = "Checks whether the root user has an access key."
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "multi_region_cloudtrail_enabled" {
  name        = "${var.project_name}-${var.environment}-multi-region-cloudtrail-enabled"
  description = "Checks whether AWS CloudTrail is enabled in all regions."
  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_s3_bucket" "cloudtrail_logs_access" {
  bucket_prefix = "ct-access-logs-"
  force_destroy = var.log_bucket_force_destroy
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs_access" {
  bucket                  = aws_s3_bucket.cloudtrail_logs_access.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs_access" {
  # AES256, not the aws:kms CMK main_tf_v1.0.md:655 otherwise
  # mandates: an S3 server-access-logging TARGET bucket cannot
  # use SSE-KMS.  "The destination bucket must use Amazon S3
  # managed keys (SSE-S3). If the destination bucket uses
  # SSE-KMS, Amazon S3 might deliver log objects that are
  # encrypted with a key that you can't access."
  # -- docs.aws.amazon.com/AmazonS3/latest/userguide/
  #    enable-server-access-logging.html
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs_access" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_logging" "cloudtrail_logs_access" {
  bucket        = aws_s3_bucket.cloudtrail_logs.id
  target_bucket = aws_s3_bucket.cloudtrail_logs_access.id
  target_prefix = "access-logs/"
}