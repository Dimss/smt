variable "vpc_id" {
  description = "VPC ID"
}
variable "ecs_cluster_name" {
  default = "SMTCluster"
  description = "ECS cluster name"
}

variable "service_name" {
  default = "web-app"
  description = "The Service descovery service name"
}

variable "sd_dns_name" {
  default = "smt-local"
  description = "DNZ zone name for ECS service discovry"
}
