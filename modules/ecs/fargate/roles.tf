# creates an application role that the container/task runs as
resource "aws_iam_role" "app_role" {
  count              = var.create_role ? 1 : 0
  name               = "${var.app}-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.app_role_assume_role_policy.json
}

# assigns the app policy
resource "aws_iam_role_policy" "app_policy" {
  count  = (var.create_cluster && var.create_role) ? 1 : 0
  name   = "${var.app}-${var.environment}"
  role   = aws_iam_role.app_role[0].id
  policy = data.aws_iam_policy_document.app_policy[0].json
}

# TODO: fill out custom policy
data "aws_iam_policy_document" "app_policy" {
  count = (var.create_cluster && var.create_role) ? 1 : 0
  statement {
    actions = [
      "ecs:DescribeClusters",
    ]

    resources = [
      aws_ecs_cluster.app[0].arn,
    ]
  }
}

data "aws_caller_identity" "current" {
}

# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "app_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    principals {
      type = "AWS"

      identifiers = ["*"]
    }
  }
}

##########################################################################################

resource "aws_iam_role" "ecsTaskExecutionRole" {
  count              = var.create_role ? 1 : 0
  name               = "${var.app}-${var.environment}-ecs"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##########################################################################################

resource "aws_iam_role" "ecs_event_stream" {
  count = (var.create_cluster && var.create_role) ? 1 : 0
  name  = aws_cloudwatch_event_rule.ecs_event_stream[0].name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "ecs_event_stream" {
  count      = (var.create_cluster && var.create_role) ? 1 : 0
  role       = aws_iam_role.ecs_event_stream[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
