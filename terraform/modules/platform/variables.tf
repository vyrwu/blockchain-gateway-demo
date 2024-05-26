variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "name_prefix" {
  type    = string
  default = "ecs"
}

