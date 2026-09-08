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

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}

locals {
  az_list = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

# Networking
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.common_tags, { Name = var.project_name })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.project_name}-igw" })
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_list[count.index]
  map_public_ip_on_launch = false # RULE 12
  tags                    = merge(local.common_tags, { Name = "${var.project_name}-public-${local.az_list[count.index]}", Tier = "public" })
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_list[count.index]
  tags              = merge(local.common_tags, { Name = "${var.project_name}-private-${local.az_list[count.index]}", Tier = "private" })
}

resource "aws_subnet" "database" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.database_subnet_cidrs[count.index]
  availability_zone       = local.az_list[count.index]
  map_public_ip_on_launch = false # RULE 12
  tags                    = merge(local.common_tags, { Name = "${var.project_name}-database-${local.az_list[count.index]}", Tier = "database" })
}

resource "aws_eip" "nat" {
  count  = var.az_count # RULE: NAT Gateway one per AZ
  domain = "vpc"
  tags   = merge(local.common_tags, { Name = "${var.project_name}-eip-${count.index + 1}" })
}

resource "aws_nat_gateway" "main" {
  count         = var.az_count # RULE: NAT Gateway one per AZ
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(local.common_tags, { Name = "${var.project_name}-nat-${count.index + 1}" })
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.project_name}-rt-public" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id # default route to the internet via IGW
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.project_name}-rt-private-${count.index + 1}" })
}

resource "aws_route" "private_nat" {
  count                  = var.az_count # RULE: NAT Gateway one per AZ
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id # default route to the internet via NAT
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "database" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.project_name}-rt-database-${count.index + 1}" })
}

# No default route to 0.0.0.0/0 for database subnets (RULE: Database subnets must have no route to internet gateway or NAT gateway)

resource "aws_route_table_association" "database" {
  count          = var.az_count
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}

# Security Group for VPC Endpoints (Interface type)
resource "aws_security_group" "vpce_interface" {
  name        = "${var.project_name}-${var.environment}-vpce-interface-sg"
  description = "Security group for VPC Interface Endpoints" # RULE 51
  vpc_id      = aws_vpc.main.id
  tags        = local.common_tags

  ingress {
    description = "Allow all traffic from within VPC" # RULE 51
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # RULE 8b
  }

  egress {
    description = "Allow all traffic within VPC" # RULE 51
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # RULE 8
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-db-subnet-group-" # RULE 26, 58
  subnet_ids  = aws_subnet.database[*].id
  description = "DB subnet group for ${var.project_name} RDS instances"
  tags        = local.common_tags

  lifecycle {
    create_before_destroy = true # RULE 26
  }
}

# KMS Key for CloudWatch Logs (RULE 22, 29)
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
  tags = local.common_tags
}

resource "aws_kms_alias" "logs" {
  # RULE 29: the random_id suffix makes the alias name unique per deploy, so a
  # destroy+re-deploy with the same project_name/environment never collides with
  # an alias left behind by the KMS key's pending-deletion window. The alias stays
  # human-readable in the console for audit navigation.
  # RULE 27: Phase-scoped KMS logs alias names.
  name          = "alias/${var.project_name}-${var.environment}-networking-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

# VPC Flow Logs (RULE 13, 13b, 59)
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/${var.project_name}/vpc/flow-logs"
  retention_in_days = var.log_retention_days # RULE 13, 13b
  kms_key_id        = aws_kms_key.logs.arn # RULE 22
  tags              = local.common_tags
}

resource "aws_iam_role" "flow_logs" {
  name_prefix = "${var.project_name}-flow-logs-role-" # RULE 26, 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "vpc-flow-logs.amazonaws.com" } }]
  })
  tags = local.common_tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.project_name}-flow-logs-policy"
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
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn # RULE 59: must NOT have :* suffix
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL" # RULE 13
  vpc_id               = aws_vpc.main.id
  tags                 = local.common_tags
}

# VPC Endpoints (RULE 43)
resource "aws_vpc_endpoint" "s3" {
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_id            = aws_vpc.main.id
  route_table_ids   = aws_route_table.private[*].id
  tags              = merge(local.common_tags, { Name = "${var.project_name}-s3-vpce" })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpce_interface.id]
  private_dns_enabled = true
  tags                = merge(local.common_tags, { Name = "${var.project_name}-ecr-dkr-vpce" })
}

resource "aws_vpc_endpoint" "kms" {
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.kms"
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpce_interface.id]
  private_dns_enabled = true
  tags                = merge(local.common_tags, { Name = "${var.project_name}-kms-vpce" })
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce_interface.id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce_interface.id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce_interface.id]
  tags              = var.tags
}
