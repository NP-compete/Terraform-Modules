resource "aws_cloudtrail" "default" {
  name                          = var.cloudtrail_name
  enable_logging                = var.enable_logging
  s3_bucket_name                = aws_s3_bucket.S3BucketForCloudTrail.id
  enable_log_file_validation    = var.enable_log_file_validation
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_role_arn     = aws_iam_role.CloudWatchLogIamRole.arn
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.CloudWatchLogGroup.arn
  tags                          = var.tags
  kms_key_id                    = var.kms_key_arn
  is_organization_trail         = var.is_organization_trail

  dynamic "event_selector" {
    for_each = var.event_selector
    content {
      include_management_events = lookup(event_selector.value, "include_management_events", null)
      read_write_type           = lookup(event_selector.value, "read_write_type", null)

      dynamic "data_resource" {
        for_each = lookup(event_selector.value, "data_resource", [])
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  depends_on = [aws_s3_bucket.S3BucketForCloudTrail]
}

resource "aws_s3_bucket" "S3BucketForCloudTrail" {
  bucket = var.s3_bucket_name
  acl    = "private"
  policy = <<POLICY
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "AWSCloudTrailAclCheck",
              "Effect": "Allow",
              "Principal": {
                "Service": "cloudtrail.amazonaws.com"
              },
              "Action": "s3:GetBucketAcl",
              "Resource": "arn:aws:s3:::"
          },
          {
              "Sid": "AWSCloudTrailWrite",
              "Effect": "Allow",
              "Principal": {
                "Service": "cloudtrail.amazonaws.com"
              },
              "Action": "s3:PutObject",
              "Resource": "arn:aws:s3:::/AWSLogs/*",
              "Condition": {
                  "StringEquals": {
                      "s3:x-amz-acl": "bucket-owner-full-control"
                  }
              }
          }
      ]
  }
  POLICY
}

resource "aws_cloudwatch_log_group" "CloudWatchLogGroup" {
  name = var.cloudwatchLogGroupName
  tags = var.tags
}
