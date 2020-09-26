resource "aws_ecs_cluster" "app" {
  count = var.create_cluster ? 1 : 0
  name  = "${var.app}-${var.environment}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

resource "aws_appautoscaling_target" "app_scale_target" {
  count              = var.create_service ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.app[0].name}/${aws_ecs_service.app[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_autoscale_max_instances
  min_capacity       = var.ecs_autoscale_min_instances
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.create_role ? aws_iam_role.ecsTaskExecutionRole[0].arn : var.ecsTaskExecutionRole
  task_role_arn            = var.create_role ? aws_iam_role.app_role[0].arn : var.app_role

  container_definitions = var.container_definition


  tags = var.tags
}

resource "aws_ecs_service" "app" {
  count           = var.create_service ? 1 : 0
  name            = "${var.app}-${var.environment}"
  cluster         = aws_ecs_cluster.app[count.index].id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.replicas

  network_configuration {
    security_groups = [aws_security_group.nsg_task.id]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags                    = var.tags
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  # workaround for https://github.com/hashicorp/terraform/issues/12634
  depends_on = [aws_alb_listener.http]

  # [after initial apply] don't override changes made to task_definition
  # from outside of terraform (i.e.; fargate cli)
  lifecycle {
    ignore_changes = [task_definition]
  }
}
