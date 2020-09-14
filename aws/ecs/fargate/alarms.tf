locals {
  thresholds = {
    CPUUtilizationHighThreshold    = min(max(var.cpu_utilization_high_threshold, 0), 100)
    CPUUtilizationLowThreshold     = min(max(var.cpu_utilization_low_threshold, 0), 100)
    MemoryUtilizationHighThreshold = min(max(var.memory_utilization_high_threshold, 0), 100)
    MemoryUtilizationLowThreshold  = min(max(var.memory_utilization_low_threshold, 0), 100)
    CPUReservationHighThreshold    = min(max(var.cpu_reservation_high_threshold, 0), 100)
    CPUReservationLowThreshold     = min(max(var.cpu_reservation_low_threshold, 0), 100)
    MemoryReservationHighThreshold = min(max(var.memory_reservation_high_threshold, 0), 100)
    MemoryReservationLowThreshold  = min(max(var.memory_reservation_low_threshold, 0), 100)
  }
}

## CPUReservation
resource "aws_cloudwatch_metric_alarm" "cpu_reservation_high" {
  count               = var.create_cluster ? 1 : 0
  alarm_name          = "${var.app}-${var.environment}-CPU-reservation-High-${var.cpu_reservation_high_threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = local.thresholds["CPUReservationHighThreshold"]

  alarm_actions = var.notify

  dimensions = {
    ClusterName = aws_ecs_cluster.app[0].name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_reservation_low" {
  count               = var.create_cluster ? 1 : 0
  alarm_name          = "${var.app}-${var.environment}-CPU-Reservation-Low-${var.cpu_reservation_low_threshold}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = local.thresholds["CPUReservationLowThreshold"]

  alarm_actions = var.notify

  dimensions = {
    ClusterName = aws_ecs_cluster.app[0].name
    ServiceName = aws_ecs_service.app[0].name
  }
}

## CPUUtilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count               = var.create_cluster ? 1 : 0
  alarm_name          = "${var.app}-${var.environment}-CPU-Utilization-High-${var.cpu_utilization_high_threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = local.thresholds["CPUUtilizationHighThreshold"]

  alarm_actions = [aws_appautoscaling_policy.app_up[0].arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.app[0].name
    ServiceName = aws_ecs_service.app[0].name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  count               = var.create_cluster ? 1 : 0
  alarm_name          = "${var.app}-${var.environment}-CPU-Utilization-Low-${var.cpu_utilization_low_threshold}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = local.thresholds["CPUUtilizationLowThreshold"]

  alarm_actions = [aws_appautoscaling_policy.app_down[0].arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.app[0].name
    ServiceName = aws_ecs_service.app[0].name
  }
}

## MemoryReservation
resource "aws_cloudwatch_metric_alarm" "memory_reservation_high" {
  count               = var.create_cluster ? 1 : 0
  alarm_name          = "${var.app}-${var.environment}-Memory-reservation-High-${var.memory_reservation_high_threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = local.thresholds["MemoryReservationHighThreshold"]

  alarm_actions = var.notify

  dimensions = {
    ClusterName = aws_ecs_cluster.app[0].name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_reservation_low" {
  count               = var.create_cluster ? 1 : 0
  alarm_name          = "${var.app}-${var.environment}-Memory-Reservation-Low-${var.memory_reservation_low_threshold}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = local.thresholds["MemoryReservationLowThreshold"]

  alarm_actions = var.notify

  dimensions = {
    ClusterName = aws_ecs_cluster.app[0].name
  }
}

## MemoryUtilization
resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  count               = var.create_cluster ? 1 : 0
  alarm_name          = "${var.app}-${var.environment}-Memory-Utilization-High-${var.cpu_utilization_high_threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = local.thresholds["MemoryUtilizationHighThreshold"]

  alarm_actions = [aws_appautoscaling_policy.app_up[0].arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.app[0].name
    ServiceName = aws_ecs_service.app[0].name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_low" {
  count               = var.create_cluster ? 1 : 0
  alarm_name          = "${var.app}-${var.environment}-Memory-Utilization-Low-${var.cpu_utilization_low_threshold}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = local.thresholds["MemoryUtilizationLowThreshold"]

  alarm_actions = [aws_appautoscaling_policy.app_down[0].arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.app[0].name
    ServiceName = aws_ecs_service.app[0].name
  }
}




