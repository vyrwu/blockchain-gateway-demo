locals {
  subnets = flatten([for i, v in setproduct(["public", "private"], ["a", "b"]) : {
    cidr = cidrsubnet(var.vpc_cidr_block, 4, i)
    tier = "${v[0]}"
    az   = "${var.region}${v[1]}"
  }])
  public_subnets  = { for i, subnet in local.subnets : i => subnet if subnet.tier == "public" }
  private_subnets = { for i, subnet in local.subnets : i => subnet if subnet.tier == "private" }
}

###############
# Networking
###############

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_ssm_parameter" "aws_vpc_main" {
  name  = "/${var.name_prefix}/aws_vpc_main_id"
  type  = "String"
  value = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  for_each          = local.public_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    tier = "public"
  }
}

resource "aws_route_table" "public" {
  for_each = local.public_subnets
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}


resource "aws_subnet" "private" {
  for_each          = local.private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    tier = "private"
  }
}

resource "aws_eip" "ip" {
  for_each = local.private_subnets
  domain   = "vpc"
}

resource "aws_nat_gateway" "main" {
  for_each      = local.private_subnets
  allocation_id = aws_eip.ip[each.key].id
  subnet_id     = aws_subnet.private[each.key].id
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }
}

resource "aws_route_table_association" "private" {
  for_each       = local.private_subnets
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

######
# ECS
######

resource "aws_ecs_cluster" "main" {
  name = var.name_prefix
}

resource "aws_ssm_parameter" "aws_ecs_cluster_main_id" {
  name  = "/${var.name_prefix}/aws_ecs_cluster_main_id"
  type  = "String"
  value = aws_ecs_cluster.main.id
}

resource "aws_security_group" "ecs_fargate_shared_sg" {
  description = "Share ECS Fargate Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.public_lb_access.id]
  }

  # ingress {
  #   description     = "Ingress from the private ALB"
  #   from_port       = 0
  #   to_port         = 0
  #   protocol        = "-1"
  #   security_groups = [aws_security_group.private_lb_access.id]
  # }

  ingress {
    from_port = 0
    to_port   = 0
    self      = true
    protocol  = "-1"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ssm_parameter" "aws_security_group_ecs_fargate_shared_sg_id" {
  name  = "/${var.name_prefix}/aws_security_group_ecs_fargate_shared_sg_id"
  type  = "String"
  value = aws_security_group.ecs_fargate_shared_sg.id
}

###############
# Load Balancing
###############

resource "aws_security_group" "public_lb_access" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [for subnet in aws_subnet.private : subnet.cidr_block]
  }
}

resource "aws_lb" "public" {
  name_prefix     = var.name_prefix
  security_groups = [aws_security_group.public_lb_access.id]
  subnets         = [for subnet in aws_subnet.public : subnet.id]
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
    }
  }
}

resource "aws_ssm_parameter" "aws_lb_listener_public_http_arn" {
  name  = "/${var.name_prefix}/aws_lb_listener_public_http_arn"
  type  = "String"
  value = aws_lb_listener.public_http.id
}

# resource "aws_security_group" "private_lb_access" {
#   description = "Only accept traffic from a container in the fargate container security group"
#   vpc_id      = aws_vpc.main.id
#
#   ingress {
#     description     = "allow private access to fargate ECS"
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     security_groups = [aws_security_group.fargate_container_sg.id]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = "0.0.0.0/0"
#   }
# }
#
# resource "aws_lb" "private" {
#   name_prefix     = var.name_prefix
#   internal        = true
#   security_groups = [aws_security_group.private_lb_access.id]
#   subnets         = aws_subnet.private.id
# }




