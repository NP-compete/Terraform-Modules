# -----------------------------------------------------------------------------
# API Gateway Latency Alarms
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "latency95" {
  count               = length(var.path_parts) > 0 ? length(var.path_parts) : 0
  alarm_name          = "${aws_api_gateway_resource.default.*.id[count.index]} : Latency p95 > 1000"
  alarm_description   = "Latency p95 > 1000"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  unit                = "Milliseconds"
  threshold           = 1000
  extended_statistic  = "p95"

  dimensions = {
    ApiName  = aws_api_gateway_rest_api.default.*.id[0]
    Resource = aws_api_gateway_resource.default.*.id[count.index]
    Method   = aws_api_gateway_method.default.*.http_method[count.index]
    Stage    = var.stage_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "latency99" {
  count               = length(var.path_parts) > 0 ? length(var.path_parts) : 0
  alarm_name          = "${aws_api_gateway_resource.default.*.id[count.index]} : Latency p99 > 1000"
  alarm_description   = "Latency p99 > 1000"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  unit                = "Milliseconds"
  threshold           = 1000
  extended_statistic  = "p99"

  dimensions = {
    ApiName  = aws_api_gateway_rest_api.default.*.id[0]
    Resource = aws_api_gateway_resource.default.*.id[count.index]
    Method   = aws_api_gateway_method.default.*.http_method[count.index]
    Stage    = var.stage_name
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# API Gateway 4XX Rate error Alarm
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "fourRate" {
  count                     = length(var.path_parts) > 0 ? length(var.path_parts) : 0
  alarm_name                = "${aws_api_gateway_resource.default.*.id[count.index]} : 4XX"
  alarm_description         = "4xx errors"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 5
  threshold                 = 0.02
  insufficient_data_actions = []

  treat_missing_data = "notBreaching"

  metric_query {
    id          = "errorRate"
    label       = "4XX Rate (%)"
    expression  = "error4xx / count"
    return_data = true
  }

  metric_query {
    id    = "count"
    label = "Count"

    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName  = aws_api_gateway_rest_api.default.*.id[0]
        Resource = aws_api_gateway_resource.default.*.id[count.index]
        Method   = aws_api_gateway_method.default.*.http_method[count.index]
        Stage    = var.stage_name
      }
    }

    return_data = false
  }

  metric_query {
    id    = "error4xx"
    label = "4XX Error"

    metric {
      metric_name = "4XXError"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName  = aws_api_gateway_rest_api.default.*.id[0]
        Resource = aws_api_gateway_resource.default.*.id[count.index]
        Method   = aws_api_gateway_method.default.*.http_method[count.index]
        Stage    = var.stage_name
      }
    }

    return_data = false
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# API Gateway 5XX Rate error Alarm
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "fiveRate" {
  count                     = length(var.path_parts) > 0 ? length(var.path_parts) : 0
  alarm_name                = "${aws_api_gateway_resource.default.*.id[count.index]} : 5xx"
  alarm_description         = "5xx Errors"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 5
  threshold                 = 0.02
  insufficient_data_actions = []

  treat_missing_data = "notBreaching"

  metric_query {
    id          = "errorRate"
    label       = "5XX Rate (%)"
    expression  = "error5xx / count"
    return_data = true
  }

  metric_query {
    id    = "count"
    label = "Count"

    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName  = aws_api_gateway_rest_api.default.*.id[0]
        Resource = aws_api_gateway_resource.default.*.id[count.index]
        Method   = aws_api_gateway_method.default.*.http_method[count.index]
        Stage    = var.stage_name
      }
    }

    return_data = false
  }

  metric_query {
    id    = "error5xx"
    label = "5XX Error"

    metric {
      metric_name = "5XXError"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName  = aws_api_gateway_rest_api.default.*.id[0]
        Resource = aws_api_gateway_resource.default.*.id[count.index]
        Method   = aws_api_gateway_method.default.*.http_method[count.index]
        Stage    = var.stage_name
      }
    }

    return_data = false
  }

  tags = var.tags
}
