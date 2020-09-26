resource "aws_cloudwatch_log_group" "logs" {
  name              = "/ecs/fargate//${var.app}-${var.environment}"
  retention_in_days = var.logs_retention_in_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "/ecs/fargate//${var.app}-${var.environment}-log-stream"
  log_group_name = aws_cloudwatch_log_group.logs.name
}

### Dashboard

resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "${var.app}-${var.environment}-fargate"

  dashboard_body = <<EOF
{"widgets":[{"type":"metric","x":12,"y":6,"width":12,"height":6,"properties":{"view":"timeSeries","stacked":false,"metrics":[["AWS/ECS","MemoryUtilization","ServiceName","${var.app}-${var.environment}","ClusterName","${var.app}-${var.environment}",{"color":"#1f77b4"}],[".","CPUUtilization",".",".",".",".",{"color":"#9467bd"}]],"region":"${var.region}","period":300,"title":"Memory and CPU utilization","yAxis":{"left":{"min":0,"max":100}}}},{"type":"metric","x":0,"y":6,"width":12,"height":6,"properties":{"view":"timeSeries","stacked":true,"metrics":[["AWS/ApplicationELB","HTTPCode_Target_5XX_Count","TargetGroup","${aws_alb_target_group.main.arn_suffix}","LoadBalancer","${aws_alb.main.arn_suffix}",{"period":60,"color":"#d62728","stat":"Sum"}],[".","HTTPCode_Target_4XX_Count",".",".",".",".",{"period":60,"stat":"Sum","color":"#bcbd22"}],[".","HTTPCode_Target_3XX_Count",".",".",".",".",{"period":60,"stat":"Sum","color":"#98df8a"}],[".","HTTPCode_Target_2XX_Count",".",".",".",".",{"period":60,"stat":"Sum","color":"#2ca02c"}]],"region":"${var.region}","title":"Container responses","period":300,"yAxis":{"left":{"min":0}}}},{"type":"metric","x":12,"y":0,"width":12,"height":6,"properties":{"view":"timeSeries","stacked":false,"metrics":[["AWS/ApplicationELB","TargetResponseTime","LoadBalancer","${aws_alb.main.arn_suffix}",{"period":60,"stat":"p50"}],["...",{"period":60,"stat":"p90","color":"#c5b0d5"}],["...",{"period":60,"stat":"p99","color":"#dbdb8d"}]],"region":"${var.region}","period":300,"yAxis":{"left":{"min":0,"max":3}},"title":"Container response times"}},{"type":"metric","x":12,"y":12,"width":12,"height":2,"properties":{"view":"singleValue","metrics":[["AWS/ApplicationELB","HealthyHostCount","TargetGroup","${aws_alb_target_group.main.arn_suffix}","LoadBalancer","${aws_alb.main.arn_suffix}",{"color":"#2ca02c","period":60}],[".","UnHealthyHostCount",".",".",".",".",{"color":"#d62728","period":60}]],"region":"${var.region}","period":300,"stacked":false}},{"type":"metric","x":0,"y":0,"width":12,"height":6,"properties":{"view":"timeSeries","stacked":true,"metrics":[["AWS/ApplicationELB","HTTPCode_Target_5XX_Count","LoadBalancer","${aws_alb.main.arn_suffix}",{"period":60,"stat":"Sum","color":"#d62728"}],[".","HTTPCode_Target_4XX_Count",".",".",{"period":60,"stat":"Sum","color":"#bcbd22"}],[".","HTTPCode_Target_3XX_Count",".",".",{"period":60,"stat":"Sum","color":"#98df8a"}],[".","HTTPCode_Target_2XX_Count",".",".",{"period":60,"stat":"Sum","color":"#2ca02c"}]],"region":"${var.region}","title":"Load balancer responses","period":300,"yAxis":{"left":{"min":0}}}}]}
EOF
}


###Event Stream

# cw event rule
resource "aws_cloudwatch_event_rule" "ecs_event_stream" {
  count       = var.create_cluster ? 1 : 0
  name        = "${var.app}-${var.environment}-ecs-event-stream"
  description = "Passes ecs event logs for ${var.app}-${var.environment} to a lambda that writes them to cw logs"

  event_pattern = <<PATTERN
  {
    "detail": {
      "clusterArn": ["${aws_ecs_cluster.app[0].arn}"]
    }
  }
  
PATTERN

}

resource "aws_cloudwatch_event_target" "ecs_event_stream" {
  count = var.create_cluster ? 1 : 0
  rule  = aws_cloudwatch_event_rule.ecs_event_stream[0].name
  arn   = aws_lambda_function.ecs_event_stream[0].arn
}

data "template_file" "lambda_source" {
  template = <<EOF
exports.handler = (event, context, callback) => {
  console.log(JSON.stringify(event));
}
EOF

}

data "archive_file" "lambda_zip" {
  type                    = "zip"
  source_content          = data.template_file.lambda_source.rendered
  source_content_filename = "index.js"
  output_path             = "lambda-${var.app}.zip"
}

resource "aws_lambda_permission" "ecs_event_stream" {
  count         = var.create_cluster ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_event_stream[0].arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_event_stream[0].arn
}

resource "aws_lambda_function" "ecs_event_stream" {
  count            = var.create_cluster ? 1 : 0
  function_name    = "${var.app}-${var.environment}-ecs-event-stream"
  role             = var.create_role ? aws_iam_role.ecs_event_stream[0].arn : var.app_role
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  tags             = var.tags
}

resource "aws_lambda_alias" "ecs_event_stream" {
  count            = var.create_cluster ? 1 : 0
  name             = aws_lambda_function.ecs_event_stream[0].function_name
  description      = "latest"
  function_name    = aws_lambda_function.ecs_event_stream[0].function_name
  function_version = "$LATEST"
}
