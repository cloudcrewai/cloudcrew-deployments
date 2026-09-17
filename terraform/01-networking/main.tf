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

# KMS Key and Alias for CloudWatch Logs (Flow Logs) - RULE 22, 17, 27, 29
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

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-${var.environment}-networking-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

# VPC - RULE 31
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-igw" })
}

# Subnets - RULE 1, 2, 12
resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "${var.project_name}-${var.environment}-public-${count.index + 1}", Tier = "public" })
}

resource "aws_subnet" "private_app" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_app_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "${var.project_name}-${var.environment}-private-app-${count.index + 1}", Tier = "private-app" })
}

resource "aws_subnet" "private_data" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_data_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "${var.project_name}-${var.environment}-private-data-${count.index + 1}", Tier = "private-data" })
}

# EIPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = var.az_count
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}" })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = var.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.tags, { Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}" })
  depends_on    = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-rt-public" })
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

resource "aws_route_table" "private_app" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-rt-private-app-${count.index + 1}" })
}

resource "aws_route" "private_app_nat" {
  count                  = var.az_count
  route_table_id         = aws_route_table.private_app[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id # default route to the internet via NAT
}

resource "aws_route_table_association" "private_app" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

resource "aws_route_table" "private_data" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-rt-private-data-${count.index + 1}" })
}

# No 0.0.0.0/0 route for private_data subnets as per blueprint rule "Database subnets must have no route to internet gateway or NAT gateway."

resource "aws_route_table_association" "private_data" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_data[count.index].id
}

# VPC Flow Logs - RULE 13, 13b, 59
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/${var.project_name}/vpc/flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_iam_role" "flow_logs" {
  name_prefix = "production-three-tier-flow-logs-role-" # RULE 58
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

resource "aws_flow_log" "main" {
  iam_role_arn         = aws_iam_role.flow_logs.arn
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn # RULE 59: NO ":*" suffix
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  tags                 = var.tags
}

# Security Group for VPC Interface Endpoints - RULE 51, 8, 8b
resource "aws_security_group" "vpce" {
  name        = "${var.project_name}-${var.environment}-vpce-sg"
  description = "Security group for VPC Interface Endpoints - allows inbound from VPC CIDR"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "vpce_ingress_https" {
  security_group_id = aws_security_group.vpce.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow HTTPS from within VPC for interface endpoints"
}

resource "aws_security_group_rule" "vpce_egress_all_vpc" {
  security_group_id = aws_security_group.vpce.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow all outbound traffic to within VPC"
}

# VPC Endpoints - RULE 43
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = concat(aws_route_table.private_app[*].id, aws_route_table.private_data[*].id)
  tags              = var.tags
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  subnet_ids          = concat(aws_subnet.private_app[*].id, aws_subnet.private_data[*].id)
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.logs"
  subnet_ids          = concat(aws_subnet.private_app[*].id, aws_subnet.private_data[*].id)
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "kms" {
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.kms"
  subnet_ids          = concat(aws_subnet.private_app[*].id, aws_subnet.private_data[*].id)
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags                = var.tags
}

# DB Subnet Group - RULE 26
resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-db-subnet-group-"
  subnet_ids  = aws_subnet.private_data[*].id
  description = "DB Subnet Group for ${var.project_name} ${var.environment}"
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_endpoint" "dynamodb_gateway" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private_data[*].id
  tags              = var.tags
}

resource "aws_vpc_endpoint" "ecr_docker" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpce.id]
  tags                = var.tags
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpce.id]
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpce.id]
  tags                = var.tags
}
