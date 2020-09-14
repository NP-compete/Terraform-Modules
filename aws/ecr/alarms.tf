resource "aws_cloudwatch_metric_alarm" "callcount_alert" {
  alarm_name          = "${var.repo_name}-callcount"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CallCount"
  namespace           = "AWS/USAGE"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"
  treat_missing_data  = "missing"
  datapoints_to_alarm = "1"

  dimensions = {
    Class  = "None",
    Resource = "BatchGetImage",
    Service  = "ECR",
    Type  =  "API"
  }

  alarm_description = format(var.repo_name, "INFO", "CallCount > 5")
  alarm_actions     = var.sns_notify
}