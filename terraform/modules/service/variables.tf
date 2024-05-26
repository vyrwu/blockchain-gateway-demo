variable "service_name" {
  type = string
}

variable "replica_count" {
  type    = number
  default = 1
}

variable "port" {
  type    = number
  default = 8080
}

variable "cpu" {
  description = "Defined in CPU shares. Subject to Fargate task sizing requirements: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Defined in MiB. Subject to Fargate task sizing requirements: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size."
  type        = number
  default     = 512
}

variable "image_tag" {
  type = string
}

variable "iam_role_policy_json" {
  type    = string
  default = ""
}

variable "platform_name_prefix" {
  type    = string
  default = "ecs"
}
