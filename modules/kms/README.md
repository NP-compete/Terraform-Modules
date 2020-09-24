## Usage

```hcl
module "kms" {
  source                  = "./kms"
  enabled                 = true
  alias                   = "alias/kms-key"
  description             = "KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = ""
  tags = {
    Hello = "voilaa"
  }
}

data "aws_kms_ciphertext" "oauth" {
  key_id = module.kms.key_id

  plaintext = <<EOF
{
  "client_id": "e587dbae22222f55da22",
  "client_secret": "8289575d00000ace55e1815ec13673955721b8a5"
}
EOF
}

output "ciphertext" {
  value = data.aws_kms_ciphertext.oauth.ciphertext_blob
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alias | The display name of the alias. The name must start with the word `alias` followed by a forward slash | `string` | `""` | no |
| deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource | `number` | `10` | no |
| description | The description of the key as viewed in AWS console | `string` | `"Parameter Store KMS master key"` | no |
| enable\_key\_rotation | Specifies whether key rotation is enabled | `bool` | `true` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | true | no |
| policy | A valid KMS policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. | `string` | `""` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alias\_arn | Alias ARN |
| alias\_name | Alias name |
| key\_arn | Key ARN |
| key\_id | Key ID |