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

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false # RULE 12
  tags                    = var.tags
}

resource "aws_subnet" "private" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false # RULE 12
  tags                    = var.tags
}

resource "aws_subnet" "db" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.db_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false # RULE 12
  tags                    = var.tags
}

resource "aws_eip" "nat" {
  count  = var.az_count
  domain = "vpc"
  tags   = var.tags
}

resource "aws_nat_gateway" "main" {
  count         = var.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = var.tags
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_route" "private_nat" {
  count                  = var.az_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "db" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

# No internet route for DB subnets

resource "aws_route_table_association" "db" {
  count          = var.az_count
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db[count.index].id
}

resource "aws_kms_key" "logs" {
  description             = "${var.project_name}-${var.environment}-logs-cmk"
  deletion_window_in_days = 30 # RULE 17
  enable_key_rotation     = true # RULE 17
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

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "logs" {
  # RULE 29: the random_id suffix makes the alias name unique per deploy, so a
  # destroy+re-deploy with the same project_name/environment never collides with
  # an alias left behind by the KMS key's pending-deletion window. The alias stays
  # human-readable in the console for audit navigation.
  name          = "alias/${var.project_name}-${var.environment}-networking-logs-${random_id.kms_logs_suffix.hex}" # RULE 27
  target_key_id = aws_kms_key.logs.key_id
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/${var.project_name}/vpc/flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn # RULE 22
  tags              = var.tags
}

resource "aws_iam_role" "flow_logs" {
  name_prefix = "aurora-serverless-v2-p-flow-logs-role-" # RULE 26
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true # RULE 26
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
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/${var.project_name}/*" # RULE 13b
      },
      {
        Action   = ["logs:DescribeLogGroups"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/${var.project_name}/*" # RULE 13b
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  iam_role_arn         = aws_iam_role.flow_logs.arn
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn # RULE 59: NO ":*" here
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL" # RULE 13
  vpc_id               = aws_vpc.main.id
  tags                 = var.tags
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer - allows HTTPS/HTTP inbound from internet" # RULE 51
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "alb_ingress_http" {
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # RULE 8b
  description       = "Allow HTTP from internet for redirect" # RULE 51
}

resource "aws_security_group_rule" "alb_ingress_https" {
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # RULE 8b
  description       = "Allow HTTPS from internet" # RULE 51
}

resource "aws_security_group_rule" "alb_egress_vpc" {
  security_group_id = aws_security_group.alb.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr] # RULE 8 Pattern A
  description       = "Allow all outbound traffic within VPC" # RULE 51
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Security group for application instances" # RULE 51
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "app_egress_db" {
  security_group_id        = aws_security_group.app.id
  type                     = "egress"
  from_port                = 5432 # PostgreSQL default port
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db.id # RULE 55
  description              = "Allow outbound to DB instances" # RULE 51
}

resource "aws_security_group_rule" "app_egress_secrets_manager_vpce" {
  security_group_id        = aws_security_group.app.id
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpce_secrets_manager.id # RULE 55
  description              = "Allow outbound to Secrets Manager VPC Endpoint" # RULE 51
}

resource "aws_security_group_rule" "app_egress_kms_vpce" {
  security_group_id        = aws_security_group.app.id
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpce_kms.id # RULE 55
  description              = "Allow outbound to KMS VPC Endpoint" # RULE 51
}

resource "aws_security_group_rule" "app_egress_vpc" {
  security_group_id = aws_security_group.app.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr] # RULE 8 Pattern A
  description       = "Allow all outbound traffic within VPC" # RULE 51
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Security group for database instances" # RULE 51
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "db_ingress_app" {
  security_group_id        = aws_security_group.db.id
  type                     = "ingress"
  from_port                = 5432 # PostgreSQL default port
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "Allow inbound from application instances" # RULE 51
}

resource "aws_security_group_rule" "db_egress_secrets_manager_vpce" {
  security_group_id        = aws_security_group.db.id
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpce_secrets_manager.id # RULE 55
  description              = "Allow outbound to Secrets Manager VPC Endpoint" # RULE 51
}

resource "aws_security_group_rule" "db_egress_kms_vpce" {
  security_group_id        = aws_security_group.db.id
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpce_kms.id # RULE 55
  description              = "Allow outbound to KMS VPC Endpoint" # RULE 51
}

resource "aws_security_group_rule" "db_egress_vpc" {
  security_group_id = aws_security_group.db.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr] # RULE 8 Pattern A
  description       = "Allow all outbound traffic within VPC" # RULE 51
}

resource "aws_security_group" "vpce_secrets_manager" {
  name        = "${var.project_name}-${var.environment}-vpce-secrets-manager-sg"
  description = "Security group for Secrets Manager VPC Endpoint" # RULE 51
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "vpce_secrets_manager_ingress_app" {
  security_group_id        = aws_security_group.vpce_secrets_manager.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "Allow inbound from application instances" # RULE 51
}

resource "aws_security_group_rule" "vpce_secrets_manager_ingress_db" {
  security_group_id        = aws_security_group.vpce_secrets_manager.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db.id
  description              = "Allow inbound from database instances" # RULE 51
}

resource "aws_security_group_rule" "vpce_secrets_manager_egress_vpc" {
  security_group_id = aws_security_group.vpce_secrets_manager.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr] # RULE 8 Pattern A
  description       = "Allow all outbound traffic within VPC" # RULE 51
}

resource "aws_security_group" "vpce_kms" {
  name        = "${var.project_name}-${var.environment}-vpce-kms-sg"
  description = "Security group for KMS VPC Endpoint" # RULE 51
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "vpce_kms_ingress_app" {
  security_group_id        = aws_security_group.vpce_kms.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "Allow inbound from application instances" # RULE 51
}

resource "aws_security_group_rule" "vpce_kms_ingress_db" {
  security_group_id        = aws_security_group.vpce_kms.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db.id
  description              = "Allow inbound from database instances" # RULE 51
}

resource "aws_security_group_rule" "vpce_kms_egress_vpc" {
  security_group_id = aws_security_group.vpce_kms.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr] # RULE 8 Pattern A
  description       = "Allow all outbound traffic within VPC" # RULE 51
}

resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-db-subnet-group-" # RULE 26
  subnet_ids  = aws_subnet.db[*].id
  tags        = var.tags

  lifecycle {
    create_before_destroy = true # RULE 26
  }
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce_secrets_manager.id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce_kms.id]
  tags              = var.tags
}
