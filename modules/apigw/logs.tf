resource "aws_api_gateway_account" "demo" {
  count = var.api_log_enabled ? 1 : 0
  cloudwatch_role_arn = var.create_role ? aws_iam_role.cloudwatch.*.arn[0] : var.cloudwatchRole
}

resource "aws_iam_role" "cloudwatch" {
  count = var.create_role ? 1 : 0

  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  count = var.create_role ? 1 : 0

  name = "default"
  role = aws_iam_role.cloudwatch.*.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_method_settings" "general_settings" {
  count = var.api_log_enabled ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.default.*.id[0]
  stage_name  = aws_api_gateway_deployment.default.*.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled        = true
    data_trace_enabled     = true
    logging_level          = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}