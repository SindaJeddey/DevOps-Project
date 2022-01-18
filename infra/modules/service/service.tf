resource "aws_ecs_task_definition" "main" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  family                   = var.name

  cpu                   = 256
  memory                = 512
  execution_role_arn    = var.ecs_task_execution_role_arn
  task_role_arn         = var.ecs_task_role_arn
  container_definitions = jsonencode([
    {
      name         = "${var.name}-container-${var.environment}"
      image        = "${var.container_image}"
      essential    = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.port
          hostPort      = var.port
        }
      ]
    }
  ])
}
resource "aws_service_discovery_service" "main" {
  name = var.name

  dns_config {
    namespace_id = var.namespace_id

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
resource "aws_ecs_service" "service" {
  name                               = "${var.name}-service-${var.environment}"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  service_registries  {
    registry_arn = aws_service_discovery_service.main.arn

  }
  network_configuration {
    security_groups  = [aws_security_group.sg.id]
    subnets          = var.subnets
    assign_public_ip = var.public_ip
  }
}

resource "aws_security_group" "sg" {
  name   = "${var.name}-sg-task-${var.environment}"
  vpc_id = var.vpc_id
  ingress {
    protocol         = "tcp"
    from_port        = var.port
    to_port          = var.port
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