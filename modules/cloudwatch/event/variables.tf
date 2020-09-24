variable "cloudwatch_event_rule_description" {
  type        = string
  description = "The description of the rule."
  default     = ""
}

variable "cloudwatch_event_rule_pattern" {
  description = "Event pattern described a HCL map which will be encoded as JSON with jsonencode function. See full documentation of CloudWatch Events and Event Patterns for details. http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/CloudWatchEventsandEventPatterns.html"
}

variable "cloudwatch_event_rule_is_enabled" {
  type        = bool
  description = "Whether the rule should be enabled."
  default     = true
}

variable "cloudwatch_event_target_id" {
  type        = string
  description = "The unique target assignment ID. If missing, will generate a random, unique id."
  default     = null
}

variable "cloudwatch_event_target_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) associated of the target."
}

var.cloudwatch_event_target_input
variable "cloudwatch_event_target_input" {
  type        = string
  description = " Valid JSON text passed to the target."
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Tags"
}
