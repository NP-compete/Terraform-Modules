resource "aws_iam_role" "CloudWatchLogIamRole" {
  name               = "CloudTrail_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["cloudtrail.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "CloudWatchLogIamRoleInlinePolicyRoleAttachment0" {
  name   = "allow-access-to-cloudwatch-logs"
  role   = aws_iam_role.CloudWatchLogIamRole.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}
