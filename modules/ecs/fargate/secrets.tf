locals {
  # KMS write actions
  kms_write_actions = [
    "kms:CancelKeyDeletion",
    "kms:CreateAlias",
    "kms:CreateGrant",
    "kms:CreateKey",
    "kms:DeleteAlias",
    "kms:DeleteImportedKeyMaterial",
    "kms:DisableKey",
    "kms:DisableKeyRotation",
    "kms:EnableKey",
    "kms:EnableKeyRotation",
    "kms:Encrypt",
    "kms:GenerateDataKey",
    "kms:GenerateDataKeyWithoutPlaintext",
    "kms:GenerateRandom",
    "kms:GetKeyPolicy",
    "kms:GetKeyRotationStatus",
    "kms:GetParametersForImport",
    "kms:ImportKeyMaterial",
    "kms:PutKeyPolicy",
    "kms:ReEncryptFrom",
    "kms:ReEncryptTo",
    "kms:RetireGrant",
    "kms:RevokeGrant",
    "kms:ScheduleKeyDeletion",
    "kms:TagResource",
    "kms:UntagResource",
    "kms:UpdateAlias",
    "kms:UpdateKeyDescription",
  ]

  # KMS read actions
  kms_read_actions = [
    "kms:Decrypt",
    "kms:DescribeKey",
    "kms:List*",
  ]

  # secretsmanager write actions
  sm_write_actions = [
    "secretsmanager:CancelRotateSecret",
    "secretsmanager:CreateSecret",
    "secretsmanager:DeleteSecret",
    "secretsmanager:PutSecretValue",
    "secretsmanager:RestoreSecret",
    "secretsmanager:RotateSecret",
    "secretsmanager:TagResource",
    "secretsmanager:UntagResource",
    "secretsmanager:UpdateSecret",
    "secretsmanager:UpdateSecretVersionStage",
  ]

  # secretsmanager read actions
  sm_read_actions = [
    "secretsmanager:DescribeSecret",
    "secretsmanager:List*",
    "secretsmanager:GetRandomPassword",
    "secretsmanager:GetSecretValue",
  ]

  # list of saml users for policies
  saml_user_ids = flatten([
    data.aws_caller_identity.current.user_id,
    data.aws_caller_identity.current.account_id
  ])

  # list of role users and saml users for policies
  role_and_saml_ids = flatten([
    "${aws_iam_role.app_role[0].unique_id}:*",
    "${aws_iam_role.ecsTaskExecutionRole[0].unique_id}:*",
    local.saml_user_ids,
  ])

  sm_arn = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-??????"
}


# create the KMS key for this secret
resource "aws_kms_key" "sm_kms_key" {
  description = "${var.app}-${var.environment}"
  policy      = data.aws_iam_policy_document.kms_resource_policy_doc.json
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", var.app, var.environment)
    },
  )
}

# alias for the key
resource "aws_kms_alias" "sm_kms_alias" {
  name          = "alias/${var.app}-${var.environment}"
  target_key_id = aws_kms_key.sm_kms_key.key_id
}

# the kms key policy
data "aws_iam_policy_document" "kms_resource_policy_doc" {
  statement {
    sid    = "DenyWriteToAllExceptSAMLUsers"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = local.kms_write_actions
    resources = ["*"]

    condition {
      test     = "StringNotLike"
      variable = "aws:userId"
      values   = local.saml_user_ids
    }
  }

  statement {
    sid    = "DenyReadToAllExceptRoleAndSAMLUsers"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = local.kms_read_actions
    resources = ["*"]

    condition {
      test     = "StringNotLike"
      variable = "aws:userId"
      values   = local.role_and_saml_ids
    }
  }

  statement {
    sid    = "AllowWriteToSAMLUsers"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = local.kms_write_actions
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:userId"
      values   = local.saml_user_ids
    }
  }

  statement {
    sid    = "AllowReadRoleAndSAMLUsers"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = local.kms_read_actions
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:userId"
      values   = local.role_and_saml_ids
    }
  }
}
