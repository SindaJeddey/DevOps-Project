terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.72.0"
    }
  }

  backend "s3" {
    bucket  = "sindajeddey"
    key     = "terraform.tfstate"
    region  = "eu-west-3"
    profile = "sandbox"
  }
}

provider "aws" {
  region  = "eu-west-3"
  profile = "sandbox"
}


module "vpc" {
  source                               = "terraform-aws-modules/vpc/aws"
  # The rest of arguments are omitted for brevity
  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  one_nat_gateway_per_az               = false
  #  Skip creation of EIPs for the NAT Gateways
  reuse_nat_ips                        = true
  #  IPs specified here as input to the module
  external_nat_ip_ids                  = "${aws_eip.nat.*.id}"
  name                                 = var.name
  cidr                                 = "10.0.0.0/26"
  # 10.0.0.0/8 is reserved for EC2-Classic
  azs                                  = [
    "${var.region}a"
  ]
  private_subnets                      = [
    "10.0.0.0/27"
  ]
  public_subnets                       = [
    "10.0.0.32/28"
  ]
  enable_dhcp_options                  = true
  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
}
resource "aws_eip" "nat" {
  vpc = true
}
resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster-${var.environment}"
}
resource "aws_ecs_task_definition" "backend" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  family                   = "backend"

  cpu                   = 256
  memory                = 512
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name         = "${var.name}-container-${var.environment}"
      image        = "${var.backend_container_image}:${var.environment}"
      essential    = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}
resource "aws_ecs_task_definition" "prometheus" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  family                   = "prometheus"

  cpu                   = 256
  memory                = 512
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name         = "${var.name}-container-${var.environment}"
      image        = "${var.prometheus_container_image}:${var.environment}"
      essential    = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 9090
          hostPort      = 9090
        }
      ]
    }
  ])
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "devops"
  description = "Service Discovery"
  vpc         = module.vpc.vpc_id
}

resource "aws_service_discovery_service" "backend" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
resource "aws_service_discovery_service" "prometheus" {
  name = "prometheus"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
resource "aws_ecs_service" "backend" {
  name                               = "backend-service-${var.environment}"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.backend.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }
  network_configuration {
    security_groups  = [aws_security_group.backend.id]
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
  }
}
resource "aws_ecs_service" "prometheus" {
  name                               = "prometheus-service-${var.environment}"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.prometheus.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  service_registries {
    registry_arn = aws_service_discovery_service.prometheus.arn
  }
  network_configuration {
    security_groups  = [aws_security_group.prometheus.id]
    #    subnets          = module.vpc.private_subnets
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
  }
}
/// SG
resource "aws_security_group" "backend" {
  name   = "backend-sg-task-${var.environment}"
  vpc_id = module.vpc.vpc_id
  ingress {
    protocol         = "tcp"
    from_port        = 5000
    to_port          = 5000
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_security_group" "prometheus" {
  name   = "prometheus-sg-task-${var.environment}"
  vpc_id = module.vpc.vpc_id
  ingress {
    protocol         = "tcp"
    from_port        = 9090
    to_port          = 9090
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
// Roles
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "dynamodb" {
  name        = "${var.name}-task-policy-dynamodb"
  description = "Policy that allows access to DynamoDB"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "dynamodb:*"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}