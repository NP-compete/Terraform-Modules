variable "tags" {
  description = "The tags to be used in the product"
  type        = map
  default     = {}
}

variable "product_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "The environment to run terraform"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "THe region"
  type        = string
  default     = "us-east-1"
}

variable "kms_name" {
  description = "The alias of the KMS key"
  type = string
}

variable "ecr_name" {
  description = "The name of ECR Repo"
  type        = string
}

variable "container_name" {
  description = "The name of container"
  type        = string
}

variable "container_image" {
  description = "The image"
  type        = string
}

variable "container_port" {
  description = "The port of the container"
  type        = number
}

variable "scale_up_cron" {
  description = "The cron to scale up your ECS Fargate cluster"
  type        = string
  default     = "cron(0 11 ? * MON-FRI *)"
}

variable "scale_down_cron" {
  description = "The cron to scale down your ECS Fargate cluster"
  type        = string
  default     = "cron(0 23 * * ? *)"
}
