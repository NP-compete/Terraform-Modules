
variable "region" {
  description = "The AWS region to use for the dev environment's infrastructure"
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags for the infrastructure"
  type        = map(string)
  default     = {}
}

variable "app" {
  description = "Name of the app"
  type        = string
  default     = "ecs-app"
}


variable "environment" {
  description = "The environment that is being built"
  type        = string
  default     = "dev"
}

# The port the container will listen on, used for load balancer health check
# Best practice is that this value is higher than 1024 so the container processes
# isn't running at root.
variable "container_port" {
  description = "App port to expose"
  type        = number
  default     = 80
}

# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "HTTP"
}

variable "vpc" {
  description = "The VPC to use for the Fargate cluster"
  type        = string
  default     = ""
}

# 
variable "private_subnets" {
  description = "The private subnets, minimum of 2, that are a part of the VPC(s)"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "The public subnets, minimum of 2, that are a part of the VPC(s)"
  type        = list(string)
  default     = []
}

variable "replicas" {
  description = "How many containers to run"
  default     = "1"
}

variable "container_name" {
  description = "The name of the container to run"
  default     = "app"
}

variable "container_image" {
  description = "The image of the container to run"
  default     = "app"
}

# For production, consider using at least "2".
variable "ecs_autoscale_min_instances" {
  description = "The minimum number of containers that should be running."
  default     = "1"
}

variable "ecs_autoscale_max_instances" {
  description = "The maximum number of containers that should be running."
  default     = "8"
}

variable "logs_retention_in_days" {
  type        = number
  default     = 90
  description = "Specifies the number of days you want to retain log events"
}

# If the average CPU utilization over a minute drops to this threshold,
# the number of containers will be reduced (but not below ecs_autoscale_min_instances).
variable "cpu_utilization_low_threshold" {
  default = "20"
}

# If the average CPU utilization over a minute rises to this threshold,
# the number of containers will be increased (but not above ecs_autoscale_max_instances).
variable "cpu_utilization_high_threshold" {
  default = "80"
}

variable "scale_up_cron" {
  default = "cron(0 11 ? * MON-FRI *)"
}

# Default scale down at 7 pm every day
variable "scale_down_cron" {
  default = "cron(0 23 * * ? *)"
}

# The mimimum number of containers to scale down to.
# Set this and `scale_down_max_capacity` to 0 to turn off service on the `scale_down_cron` schedule.
variable "scale_down_min_capacity" {
  default = 1
}

# The maximum number of containers to scale down to.
variable "scale_down_max_capacity" {
  default = 2
}

# Whether the application is available on the public internet,
# also will determine which subnets will be used (public or private)
variable "internal" {
  default = true
}

# The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused
variable "deregistration_delay" {
  default = "30"
}

# The path to the health check for the load balancer to know if the container(s) are ready
variable "health_check" {
  type = string
  default = ""
}

# How often to check the liveliness of the container
variable "health_check_interval" {
  default = "30"
}

# How long to wait for the response on the health check path
variable "health_check_timeout" {
  default = "10"
}

# What HTTP response code to listen for
variable "health_check_matcher" {
  default = "200"
}

variable "lb_access_logs_expiration_days" {
  default = "3"
}

variable "security_groups" {
  type        = list
  description = "The security group"
  default     = []
}

variable "container_definition" {
  description = "The container definition JSON"
  # default = data.template_file.container_definitions.rendered
}

variable "https_port" {
  default = "443"
}

# 
variable "certificate_arn" {
  description = "The ARN for the SSL certificate"
  type = string
  default = ""
}

variable "create_service" {
  description = "Boolean to create service"
  type = bool
  default = true
}

variable "create_cluster" {
  description = "Boolean to create cluster"
  type = bool
  default = true
}

variable "create_role" {
  description = "Boolean to create roles"
  type = bool
  default = true
}

variable "app_role" {
  type = string
  description = "An application role that the container/task runs as"
  default = ""
}

variable "ecsTaskExecutionRole" {
  type = string
  description = "The ECS task execution role"
  default = ""
}

variable "notify" {
  type = list(string)
  description = "A list of SNS ARN's to notify in case of an alarm"
  default = []
}

variable "memory_utilization_high_threshold" {
  type = number
  default = 80
}

variable "memory_utilization_low_threshold" {
  type = number
  default = 20
}

variable "cpu_reservation_high_threshold" {
  type = number
  default = 80
}

variable "cpu_reservation_low_threshold" {
  type = number
  default = 20
}

variable "memory_reservation_high_threshold" {
  type = number
  default = 80
}

variable "memory_reservation_low_threshold" {
  type = number
  default = 20
}