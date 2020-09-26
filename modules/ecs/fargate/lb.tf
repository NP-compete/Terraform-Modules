resource "aws_alb" "main" {
  name = "${var.app}-${var.environment}"

  # launch lbs in public or private subnets based on "internal" variable
  internal        = var.internal
  subnets         = var.internal == true ? var.private_subnets : var.public_subnets
  security_groups = var.security_groups
  tags            = var.tags

  # enable access logs in order to get support from aws
  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.lb_access_logs.bucket
  }
}

resource "aws_alb_target_group" "main" {
  name                 = "${var.app}-${var.environment}"
  port                 = var.lb_port
  protocol             = var.lb_protocol
  vpc_id               = var.vpc
  target_type          = "ip"
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  tags = var.tags
}

data "aws_elb_service_account" "main" {
}

# bucket for storing ALB access logs
resource "aws_s3_bucket" "lb_access_logs" {
  bucket        = "${var.app}-${var.environment}-lb-access-logs"
  acl           = "private"
  tags          = var.tags
  force_destroy = true

  lifecycle_rule {
    id                                     = "cleanup"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1
    prefix                                 = ""

    expiration {
      days = var.lb_access_logs_expiration_days
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# give load balancing service access to the bucket
resource "aws_s3_bucket_policy" "lb_access_logs" {
  bucket = aws_s3_bucket.lb_access_logs.id

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.lb_access_logs.arn}",
        "${aws_s3_bucket.lb_access_logs.arn}/*"
      ],
      "Principal": {
        "AWS": [ "${data.aws_elb_service_account.main.arn}" ]
      }
    }
  ]
}
POLICY
}


resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.id
  port              = var.lb_port
  protocol          = var.lb_protocol

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_security_group_rule" "ingress_lb_http" {
  type              = "ingress"
  description       = var.lb_protocol
  from_port         = var.lb_port
  to_port           = var.lb_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb.id
}




# adds an https listener to the load balancer
# (delete this file if you only want http)

# The port to listen on for HTTPS, always use 443
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.id
  port              = var.https_port
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_security_group_rule" "ingress_lb_https" {
  type              = "ingress"
  description       = "HTTPS"
  from_port         = var.https_port
  to_port           = var.https_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb.id
}
