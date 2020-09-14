resource "aws_appautoscaling_policy" "app_up" {
  count = var.create_service ? 1 : 0
  name               = "app-scale-up"
  service_namespace  = aws_appautoscaling_target.app_scale_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.app_scale_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.app_scale_target[0].scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.app_scale_target]
}

resource "aws_appautoscaling_policy" "app_down" {
  count = var.create_service ? 1 : 0
  name               = "app-scale-down"
  service_namespace  = aws_appautoscaling_target.app_scale_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.app_scale_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.app_scale_target[0].scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_appautoscaling_scheduled_action" "app_autoscale_time_up" {
  count = var.create_service ? 1 : 0
  name = "app-autoscale-time-up-${var.app}"

  service_namespace  = aws_appautoscaling_target.app_scale_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.app_scale_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.app_scale_target[0].scalable_dimension
  schedule           = var.scale_up_cron

  scalable_target_action {
    min_capacity = aws_appautoscaling_target.app_scale_target[0].min_capacity
    max_capacity = aws_appautoscaling_target.app_scale_target[0].max_capacity
  }
}

# Scales service down to capacity defined by the
# `scale_down_min_capacity` and `scale_down_max_capacity` variables.
resource "aws_appautoscaling_scheduled_action" "app_autoscale_time_down" {
  count = var.create_service ? 1 : 0
  name = "app-autoscale-time-down-${var.app}"

  service_namespace  = aws_appautoscaling_target.app_scale_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.app_scale_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.app_scale_target[0].scalable_dimension
  schedule           = var.scale_down_cron

  scalable_target_action {
    min_capacity = var.scale_down_min_capacity
    max_capacity = var.scale_down_max_capacity
  }
}