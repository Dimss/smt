variable "region" {
  default = "eu-west-1"
  description = "AWS region"
}

variable "service_name" {
  default = "web-app"
  description = "The Service descovery service name"
}

variable "sd_ns_name" {
  default = "smt-local"
  description = "DNZ zone name for ECS service discovry"
}
