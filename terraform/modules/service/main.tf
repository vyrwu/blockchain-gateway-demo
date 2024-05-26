data "aws_ssm_parameter" "ecs_fargate_cluster_id" {
  name = "/${var.platform_name_prefix}/aws_ecs_cluster_main_id"
}

data "aws_ssm_parameter" "aws_vpc_main_id" {
  name = "/${var.platform_name_prefix}/aws_vpc_main_id"
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_ssm_parameter.aws_vpc_main_id.value]
  }

  tags = {
    tier = "public"
  }
}

###########
# Routing
###########

resource "aws_lb_target_group" "target_group_public" {
  name_prefix = "ecs"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    path              = "/"
    protocol          = "HTTP"
    port              = 80
    timeout           = "5"
    healthy_threshold = "2"
    interval          = "6"
  }
  vpc_id = data.aws_ssm_parameter.aws_vpc_main_id.value
}

data "aws_ssm_parameter" "lb_lister_public_arn" {
  name = "/${var.platform_name_prefix}/aws_lb_listener_public_http_arn"
}

resource "aws_lb_listener_rule" "private" {
  listener_arn = data.aws_ssm_parameter.lb_lister_public_arn.value

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_public.arn
  }

  condition {
    path_pattern {
      values = ["/${var.service_name}"]
    }
  }
}

###########
# Service
###########

data "aws_ssm_parameter" "fargate_shared_sg_id" {
  name = "/${var.platform_name_prefix}/aws_security_group_ecs_fargate_shared_sg_id"
}

resource "aws_ecs_service" "ecs_service" {
  name                               = var.service_name
  cluster                            = data.aws_ssm_parameter.ecs_fargate_cluster_id.value
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "75"
  desired_count                      = var.replica_count

  network_configuration {
    subnets         = data.aws_subnets.public.ids
    security_groups = [data.aws_ssm_parameter.fargate_shared_sg_id.value]
  }

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.ecs_task.family}:${max(aws_ecs_task_definition.ecs_task.revision, aws_ecs_task_definition.ecs_task.revision)}"

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_public.arn
    container_name   = var.service_name
    container_port   = var.port
  }
}

resource "aws_ecr_repository" "service" {
  name = var.service_name

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "task_role" {
  count              = var.iam_role_policy_json != "" ? 1 : 0
  name               = "${var.service_name}-task-role"
  assume_role_policy = var.iam_role_policy_json
}

data "aws_iam_policy" "execution_role_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "execution_role" {
  name_prefix = "${var.service_name}-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [data.aws_iam_policy.execution_role_policy.arn]
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.service_name
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = try(aws_iam_role.task_role[0].arn, null)
  execution_role_arn       = aws_iam_role.execution_role.arn

  container_definitions = jsonencode(
    [
      {
        "cpu" : var.cpu,
        "image" : aws_ecr_repository.service.repository_url,
        "memory" : var.memory,
        "name" : var.service_name
        "portMappings" : [
          {
            "containerPort" : var.port,
          }
        ]
      }
  ])
}
