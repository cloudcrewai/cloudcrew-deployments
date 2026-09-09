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
  }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


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

resource "random_id" "kms_sagemaker_suffix" {
  byte_length = 4
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

# KMS Key for SageMaker and CloudWatch Logs (RULE 17, 22, 29, 49)
resource "aws_kms_key" "main" {
  description             = "${var.project_name}-${var.environment}-sagemaker-cmk"
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
        Sid    = "AllowSageMakerService"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
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
      }
    ]
  })
  tags = var.tags
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-sagemaker-${random_id.kms_sagemaker_suffix.hex}"
  target_key_id = aws_kms_key.main.key_id
}

# ECR Repository (RULE 47)
resource "aws_ecr_repository" "sagemaker_images" {
  name                 = "${var.project_name}-${var.environment}-sagemaker-custom-images"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "sagemaker_images" {
  repository = aws_ecr_repository.sagemaker_images.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Remove untagged images after 14 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 14
      }
      action = { type = "expire" }
    }]
  })
}

# IAM Role for SageMaker (SageMaker IAM role rule)
resource "aws_iam_role" "sagemaker_execution" {
  name_prefix        = "sagemaker-ml-platform-sagemaker-exec-" # RULE 26
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "sagemaker.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "sagemaker_execution" {
  name = "${var.project_name}-${var.environment}-sagemaker-exec-policy"
  role = aws_iam_role.sagemaker_execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          data.terraform_remote_state.data.outputs.s3_training_data_bucket_arn,
          "${data.terraform_remote_state.data.outputs.s3_training_data_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          data.terraform_remote_state.data.outputs.s3_model_artifacts_bucket_arn,
          "${data.terraform_remote_state.data.outputs.s3_model_artifacts_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = aws_ecr_repository.sagemaker_images.arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "kms:Decrypt"
        ]
        Resource = data.terraform_remote_state.data.outputs.kms_s3_key_arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.main.arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*" # CloudWatch Logs resource ARNs can be complex, using * for simplicity here, but ideally more specific.
      },
      {
        Effect   = "Allow"
        Action   = [
          "sagemaker:CreateTrainingJob",
          "sagemaker:DescribeTrainingJob",
          "sagemaker:StopTrainingJob",
          "sagemaker:CreateProcessingJob",
          "sagemaker:DescribeProcessingJob",
          "sagemaker:StopProcessingJob",
          "sagemaker:CreateTransformJob",
          "sagemaker:DescribeTransformJob",
          "sagemaker:StopTransformJob",
          "sagemaker:CreateModel",
          "sagemaker:CreateEndpointConfig",
          "sagemaker:CreateEndpoint",
          "sagemaker:DescribeEndpoint",
          "sagemaker:DeleteEndpoint",
          "sagemaker:DeleteEndpointConfig",
          "sagemaker:InvokeEndpoint",
          "sagemaker:UpdateEndpoint",
          "sagemaker:UpdateEndpointWeightsAndCapacities",
          "sagemaker:CreateNotebookInstance",
          "sagemaker:DescribeNotebookInstance",
          "sagemaker:StopNotebookInstance",
          "sagemaker:StartNotebookInstance",
          "sagemaker:DeleteNotebookInstance",
          "sagemaker:CreatePresignedNotebookInstanceUrl",
          "sagemaker:CreatePresignedDomainUrl",
          "sagemaker:CreatePresignedAppUrl",
          "sagemaker:CreateApp",
          "sagemaker:DescribeApp",
          "sagemaker:DeleteApp",
          "sagemaker:CreateDomain",
          "sagemaker:DescribeDomain",
          "sagemaker:DeleteDomain",
          "sagemaker:CreateUserProfile",
          "sagemaker:DescribeUserProfile",
          "sagemaker:DeleteUserProfile",
          "sagemaker:CreateStudioLifecycleConfig",
          "sagemaker:DescribeStudioLifecycleConfig",
          "sagemaker:DeleteStudioLifecycleConfig",
          "sagemaker:CreateFlowDefinition",
          "sagemaker:DescribeFlowDefinition",
          "sagemaker:DeleteFlowDefinition",
          "sagemaker:CreateHumanTaskUi",
          "sagemaker:DescribeHumanTaskUi",
          "sagemaker:DeleteHumanTaskUi",
          "sagemaker:CreateLabelingJob",
          "sagemaker:DescribeLabelingJob",
          "sagemaker:StopLabelingJob",
          "sagemaker:CreateHyperParameterTuningJob",
          "sagemaker:DescribeHyperParameterTuningJob",
          "sagemaker:StopHyperParameterTuningJob",
          "sagemaker:CreateMonitoringSchedule",
          "sagemaker:DescribeMonitoringSchedule",
          "sagemaker:DeleteMonitoringSchedule",
          "sagemaker:StopMonitoringSchedule",
          "sagemaker:StartMonitoringSchedule",
          "sagemaker:UpdateMonitoringSchedule",
          "sagemaker:CreateDataQualityJobDefinition",
          "sagemaker:DescribeDataQualityJobDefinition",
          "sagemaker:DeleteDataQualityJobDefinition",
          "sagemaker:CreateModelPackageGroup",
          "sagemaker:DescribeModelPackageGroup",
          "sagemaker:DeleteModelPackageGroup",
          "sagemaker:CreateModelPackage",
          "sagemaker:DescribeModelPackage",
          "sagemaker:DeleteModelPackage",
          "sagemaker:UpdateModelPackage",
          "sagemaker:ListModelPackages",
          "sagemaker:ListModelPackageGroups",
          "sagemaker:ListTrainingJobs",
          "sagemaker:ListProcessingJobs",
          "sagemaker:ListTransformJobs",
          "sagemaker:ListEndpoints",
          "sagemaker:ListEndpointConfigs",
          "sagemaker:ListModels",
          "sagemaker:ListNotebookInstances",
          "sagemaker:ListDomains",
          "sagemaker:ListUserProfiles",
          "sagemaker:ListApps",
          "sagemaker:ListStudioLifecycleConfigs",
          "sagemaker:ListFlowDefinitions",
          "sagemaker:ListHumanTaskUis",
          "sagemaker:ListLabelingJobs",
          "sagemaker:ListHyperParameterTuningJobs",
          "sagemaker:ListMonitoringSchedules",
          "sagemaker:ListDataQualityJobDefinitions",
          "sagemaker:ListTags",
          "sagemaker:AddTags",
          "sagemaker:DeleteTags",
          "sagemaker:UpdateEndpointWeightsAndCapacities",
          "sagemaker:UpdateEndpoint",
          "sagemaker:UpdateModelPackageGroup",
          "sagemaker:UpdateDomain",
          "sagemaker:UpdateUserProfile",
          "sagemaker:UpdateApp",
          "sagemaker:UpdateNotebookInstance",
          "sagemaker:UpdateTrainingJob",
          "sagemaker:UpdateProcessingJob",
          "sagemaker:UpdateTransformJob",
          "sagemaker:UpdateModel",
          "sagemaker:UpdateEndpointConfig",
          "sagemaker:UpdateFeatureGroup",
          "sagemaker:CreateFeatureGroup",
          "sagemaker:DescribeFeatureGroup",
          "sagemaker:DeleteFeatureGroup",
          "sagemaker:ListFeatureGroups",
          "sagemaker:CreateImage",
          "sagemaker:DescribeImage",
          "sagemaker:DeleteImage",
          "sagemaker:ListImages",
          "sagemaker:CreateImageVersion",
          "sagemaker:DescribeImageVersion",
          "sagemaker:DeleteImageVersion",
          "sagemaker:ListImageVersions",
          "sagemaker:UpdateImage",
          "sagemaker:UpdateImageVersion",
          "sagemaker:CreateCodeRepository",
          "sagemaker:DescribeCodeRepository",
          "sagemaker:DeleteCodeRepository",
          "sagemaker:ListCodeRepositories",
          "sagemaker:UpdateCodeRepository",
          "sagemaker:CreateProject",
          "sagemaker:DescribeProject",
          "sagemaker:DeleteProject",
          "sagemaker:ListProjects",
          "sagemaker:UpdateProject",
          "sagemaker:CreatePipeline",
          "sagemaker:DescribePipeline",
          "sagemaker:DeletePipeline",
          "sagemaker:ListPipelines",
          "sagemaker:UpdatePipeline",
          "sagemaker:StartPipelineExecution",
          "sagemaker:StopPipelineExecution",
          "sagemaker:ListPipelineExecutions",
          "sagemaker:DescribePipelineExecution",
          "sagemaker:ListPipelineExecutionSteps",
          "sagemaker:ListPipelineParametersForExecution",
          "sagemaker:CreateExperiment",
          "sagemaker:DescribeExperiment",
                          "sagemaker:DeleteExperiment",
          "sagemaker:ListExperiments",
          "sagemaker:UpdateExperiment",
          "sagemaker:CreateTrial",
          "sagemaker:DescribeTrial",
          "sagemaker:DeleteTrial",
          "sagemaker:ListTrials",
          "sagemaker:UpdateTrial",
          "sagemaker:CreateTrialComponent",
          "sagemaker:DescribeTrialComponent",
          "sagemaker:DeleteTrialComponent",
          "sagemaker:ListTrialComponents",
          "sagemaker:UpdateTrialComponent",
          "sagemaker:AssociateTrialComponent",
          "sagemaker:DisassociateTrialComponent",
          "sagemaker:CreateContext",
          "sagemaker:DescribeContext",
          "sagemaker:DeleteContext",
          "sagemaker:ListContexts",
          "sagemaker:UpdateContext",
          "sagemaker:CreateArtifact",
          "sagemaker:DescribeArtifact",
          "sagemaker:DeleteArtifact",
          "sagemaker:ListArtifacts",
          "sagemaker:UpdateArtifact",
          "sagemaker:CreateAction",
          "sagemaker:DescribeAction",
          "sagemaker:DeleteAction",
          "sagemaker:ListActions",
          "sagemaker:UpdateAction",
          "sagemaker:AddAssociation",
          "sagemaker:DeleteAssociation",
          "sagemaker:ListAssociations",
          "sagemaker:CreateDeviceFleet",
          "sagemaker:DescribeDeviceFleet",
          "sagemaker:DeleteDeviceFleet",
          "sagemaker:ListDeviceFleets",
          "sagemaker:UpdateDeviceFleet",
          "sagemaker:RegisterDevices",
          "sagemaker:ListDevices",
          "sagemaker:CreateEdgePackagingJob",
          "sagemaker:DescribeEdgePackagingJob",
          "sagemaker:StopEdgePackagingJob",
          "sagemaker:ListEdgePackagingJobs",
          "sagemaker:CreateCompilationJob",
          "sagemaker:DescribeCompilationJob",
          "sagemaker:StopCompilationJob",
          "sagemaker:ListCompilationJobs",
          "sagemaker:CreateMonitoringSchedule",
          "sagemaker:DescribeMonitoringSchedule",
          "sagemaker:DeleteMonitoringSchedule",
          "sagemaker:StopMonitoringSchedule",
          "sagemaker:StartMonitoringSchedule",
          "sagemaker:UpdateMonitoringSchedule",
          "sagemaker:CreateDataQualityJobDefinition",
          "sagemaker:DescribeDataQualityJobDefinition",
          "sagemaker:DeleteDataQualityJobDefinition",
          "sagemaker:CreateModelQualityJobDefinition",
          "sagemaker:DescribeModelQualityJobDefinition",
          "sagemaker:DeleteModelQualityJobDefinition",
          "sagemaker:CreateModelBiasJobDefinition",
          "sagemaker:DescribeModelBiasJobDefinition",
          "sagemaker:DeleteModelBiasJobDefinition",
          "sagemaker:CreateModelExplainabilityJobDefinition",
          "sagemaker:DescribeModelExplainabilityJobDefinition",
          "sagemaker:DeleteModelExplainabilityJobDefinition",
          "sagemaker:CreateEndpointConfig",
          "sagemaker:CreateEndpoint",
          "sagemaker:DescribeEndpoint",
          "sagemaker:DeleteEndpoint",
          "sagemaker:DeleteEndpointConfig",
          "sagemaker:InvokeEndpoint",
          "sagemaker:UpdateEndpoint",
          "sagemaker:UpdateEndpointWeightsAndCapacities",
          "sagemaker:CreateNotebookInstance",
          "sagemaker:DescribeNotebookInstance",
          "sagemaker:StopNotebookInstance",
          "sagemaker:StartNotebookInstance",
          "sagemaker:DeleteNotebookInstance",
          "sagemaker:CreatePresignedNotebookInstanceUrl",
          "sagemaker:CreatePresignedDomainUrl",
          "sagemaker:CreatePresignedAppUrl",
          "sagemaker:CreateApp",
          "sagemaker:DescribeApp",
          "sagemaker:DeleteApp",
          "sagemaker:CreateDomain",
          "sagemaker:DescribeDomain",
          "sagemaker:DeleteDomain",
          "sagemaker:CreateUserProfile",
          "sagemaker:DescribeUserProfile",
          "sagemaker:DeleteUserProfile",
          "sagemaker:CreateStudioLifecycleConfig",
          "sagemaker:DescribeStudioLifecycleConfig",
          "sagemaker:DeleteStudioLifecycleConfig",
          "sagemaker:CreateFlowDefinition",
          "sagemaker:DescribeFlowDefinition",
          "sagemaker:DeleteFlowDefinition",
          "sagemaker:CreateHumanTaskUi",
          "sagemaker:DescribeHumanTaskUi",
          "sagemaker:DeleteHumanTaskUi",
          "sagemaker:CreateLabelingJob",
          "sagemaker:DescribeLabelingJob",
          "sagemaker:StopLabelingJob",
          "sagemaker:CreateHyperParameterTuningJob",
          "sagemaker:DescribeHyperParameterTuningJob",
          "sagemaker:StopHyperParameterTuningJob",
          "sagemaker:CreateMonitoringSchedule",
          "sagemaker:DescribeMonitoringSchedule",
          "sagemaker:DeleteMonitoringSchedule",
          "sagemaker:StopMonitoringSchedule",
          "sagemaker:StartMonitoringSchedule",
          "sagemaker:UpdateMonitoringSchedule",
          "sagemaker:CreateDataQualityJobDefinition",
          "sagemaker:DescribeDataQualityJobDefinition",
          "sagemaker:DeleteDataQualityJobDefinition",
          "sagemaker:CreateProject",
          "sagemaker:DescribeProject",
          "sagemaker:DeleteProject",
          "sagemaker:ListProjects",
          "sagemaker:UpdateProject",
          "sagemaker:CreatePipeline",
          "sagemaker:DescribePipeline",
          "sagemaker:DeletePipeline",
          "sagemaker:ListPipelines",
          "sagemaker:UpdatePipeline",
          "sagemaker:StartPipelineExecution",
          "sagemaker:StopPipelineExecution",
          "sagemaker:ListPipelineExecutions",
          "sagemaker:DescribePipelineExecution",
          "sagemaker:ListPipelineExecutionSteps",
          "sagemaker:ListPipelineParametersForExecution",
          "sagemaker:CreateExperiment",
          "sagemaker:DescribeExperiment",
          "sagemaker:DeleteExperiment",
          "sagemaker:ListExperiments",
          "sagemaker:UpdateExperiment",
          "sagemaker:CreateTrial",
          "sagemaker:DescribeTrial",
          "sagemaker:DeleteTrial",
          "sagemaker:ListTrials",
          "sagemaker:UpdateTrial",
          "sagemaker:CreateTrialComponent",
          "sagemaker:DescribeTrialComponent",
          "sagemaker:DeleteTrialComponent",
          "sagemaker:ListTrialComponents",
          "sagemaker:UpdateTrialComponent",
          "sagemaker:AssociateTrialComponent",
          "sagemaker:DisassociateTrialComponent",
          "sagemaker:CreateContext",
          "sagemaker:DescribeContext",
          "sagemaker:DeleteContext",
          "sagemaker:ListContexts",
          "sagemaker:UpdateContext",
          "sagemaker:CreateArtifact",
          "sagemaker:DescribeArtifact",
          "sagemaker:DeleteArtifact",
          "sagemaker:ListArtifacts",
          "sagemaker:UpdateArtifact",
          "sagemaker:CreateAction",
          "sagemaker:DescribeAction",
          "sagemaker:DeleteAction",
          "sagemaker:ListActions",
          "sagemaker:UpdateAction",
          "sagemaker:AddAssociation",
          "sagemaker:DeleteAssociation",
          "sagemaker:ListAssociations",
          "sagemaker:CreateDeviceFleet",
          "sagemaker:DescribeDeviceFleet",
          "sagemaker:DeleteDeviceFleet",
          "sagemaker:ListDeviceFleets",
          "sagemaker:UpdateDeviceFleet",
          "sagemaker:RegisterDevices",
          "sagemaker:ListDevices",
          "sagemaker:CreateEdgePackagingJob",
          "sagemaker:DescribeEdgePackagingJob",
          "sagemaker:StopEdgePackagingJob",
          "sagemaker:ListEdgePackagingJobs",
          "sagemaker:CreateCompilationJob",
          "sagemaker:DescribeCompilationJob",
          "sagemaker:StopCompilationJob",
          "sagemaker:ListCompilationJobs"
        ]
        Resource = "*" # SageMaker actions often require * for resource, or specific ARNs for specific resources.
      }
    ]
  })
}

# Security Group for SageMaker Model VPC Config (RULE 51)
resource "aws_security_group" "sagemaker_model" {
  name        = "${var.project_name}-${var.environment}-sagemaker-model-sg"
  description = "Security group for SageMaker model VPC configuration"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  tags        = var.tags
}

# Egress rules for SageMaker Model SG (RULE 8)
resource "aws_security_group_rule" "sagemaker_model_egress_to_vpce" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.sagemaker_model.id
  source_security_group_id = aws_security_group.vpce.id
  description              = "Allow all egress to VPC Endpoints"
}

resource "aws_security_group_rule" "sagemaker_model_egress_to_vpc_cidr" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sagemaker_model.id
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  description       = "Allow all egress within VPC CIDR"
}

# Security Group for VPC Endpoints (RULE 51)
resource "aws_security_group" "vpce" {
  name        = "${var.project_name}-${var.environment}-vpce-sg"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  tags        = var.tags
}

# Ingress rules for VPC Endpoint SG (RULE 8b)
resource "aws_security_group_rule" "vpce_ingress_from_sagemaker_model" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.vpce.id
  source_security_group_id = aws_security_group.sagemaker_model.id
  description              = "Allow all ingress from SageMaker Model SG"
}

# VPC Interface Endpoints (RULE 43)
resource "aws_vpc_endpoint" "sagemaker_api" {
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  service_name        = "com.amazonaws.${var.region}.sagemaker.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "sagemaker_runtime" {
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  service_name        = "com.amazonaws.${var.region}.sagemaker.runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  service_name        = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags                = var.tags
}

# SageMaker Model Package Group (SageMaker model registry rule)
resource "aws_sagemaker_model_package_group" "main" {
  model_package_group_name        = "${var.project_name}-${var.environment}-model-group"
  model_package_group_description = "Model package group for ${var.project_name} in ${var.environment}"
  tags                            = var.tags
}

# SageMaker Model (ml_training_job output, used by inference)
resource "aws_sagemaker_model" "main" {
  name                     = "${var.project_name}-${var.environment}-model"
  execution_role_arn       = aws_iam_role.sagemaker_execution.arn
  enable_network_isolation = true # Best practice for security

  primary_container {
    image          = aws_ecr_repository.sagemaker_images.repository_url
    model_data_url = "s3://${split("/", data.terraform_remote_state.data.outputs.s3_model_artifacts_bucket_arn)[2]}/" # Placeholder for model artifact path
  }

  vpc_config {
    security_group_ids = [aws_security_group.sagemaker_model.id]
    subnets            = data.terraform_remote_state.networking.outputs.private_subnet_ids
  }
  tags = var.tags
}

# SageMaker Endpoint Configuration (ml_inference_endpoint)
resource "aws_sagemaker_endpoint_configuration" "main" {
  name_prefix = "${var.project_name}-${var.environment}-endpoint-config-" # RULE 26
  kms_key_arn = aws_kms_key.main.arn

  production_variants {
    variant_name           = "default"
    model_name             = aws_sagemaker_model.main.name
    instance_type          = var.sagemaker_instance_type_inference
    initial_instance_count = var.sagemaker_initial_instance_count_inference
  }
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# SageMaker Endpoint (ml_inference_endpoint)
resource "aws_sagemaker_endpoint" "main" {
  name                 = "${var.project_name}-${var.environment}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.main.name
  tags                 = var.tags
}

# CloudWatch Log Group for SageMaker (CloudWatch Logs rules)
resource "aws_cloudwatch_log_group" "sagemaker" {
  name              = "/aws/sagemaker"
  retention_in_days = var.log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}
