resource "aws_kms_key" "default" {
  count                   = var.enabled ? 1 : 0
  is_enabled              = var.enabled
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = var.policy
  tags                    = var.tags
  description             = var.description
}

resource "aws_kms_alias" "default" {
  count         = var.enabled ? 1 : 0
  name          = var.alias
  target_key_id = join("", aws_kms_key.default.*.id)
}
