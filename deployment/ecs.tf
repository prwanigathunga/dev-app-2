resource "aws_ecs_cluster" "main" {
  name = "main-ecs-cluster"
}

resource "aws_ecs_task_definition" "springboot_task_definition" {
  family                   = "springboot-task-1"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "springboot-container"
      image = "019839696585.dkr.ecr.us-east-1.amazonaws.com/mysql-alb-ecs-dev-app-1-repo:alb-ecs-only"
      networkMode = "awsvpc"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "springboot_service" {
  name            = "test-springboot-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.springboot_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.main_lb_tg.arn
    container_name   = "springboot-container"
    container_port   = 8080
  }
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name = "my-ecs-sg"
  description                 = "Security group for ecs app"
  revoke_rules_on_delete      = true
}

resource "aws_security_group_rule" "ecs_alb_ingress" {
  type                        = "ingress"
  from_port                   = 8080
  to_port                     = 8080
  protocol                    = "-1"
  description                 = "Allow inbound traffic from ALB"
  security_group_id           = aws_security_group.ecs_sg.id
  source_security_group_id    = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ecs_all_egress" {
  type                        = "egress"
  from_port                   = 0
  to_port                     = 0
  protocol                    = "-1"
  description                 = "Allow outbound traffic from ECS"
  security_group_id           = aws_security_group.ecs_sg.id
  cidr_blocks                 = ["0.0.0.0/0"]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}
