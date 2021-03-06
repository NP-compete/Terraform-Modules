variable "repo_name" {
  description = "Name of the repository"
  type        = "string"
}

variable "product_domain" {
  description = "The product domain that this service belongs to"
  type        = "string"
}

variable "environment" {
  description = "Environment where the service run"
  type        = "string"
}

variable "tags" {
  description = "Custom tags for ECR Repo"
  type        = "map"
  default     = {}
}

variable "lifecyle_policy" {
  description = "The lifecycle policy of this repository"
  type        = "string"
  default     = ""
}

variable "repository_policy" {
  description = "The access policy of this repository"
  type        = "string"
  default     = ""
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`"
  type        = "string"
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (`true`) or not scanned (`false`)"
  type        = string
  default     = "false"
}

variable "delete_timeout" {
  description = "How long to wait for a repository to be deleted. Check [Timeout](https://www.terraform.io/docs/configuration/resources.html#timeouts) for more detail."
  type        = string
  default     = "20m"
}

variable "sns_notify" {
  description = "SNS Topic ARN to notify in case of exceeded callcount"
  type        = list(string)
}

variable "kms_arn" {
  description = "The ARN of the KMS key to encrypt"
  type        = string
}
