variable "instace_type" {
  default = "t2.micro"
  description = "Default instance type"
}
variable "ami" {
  default = "ami-01c2c478"
  description = "ubuntu-minimal"
}

variable "private_subnet_a_id" {
  description = "Public subnet B ID"
}

variable "private_subnet_b_id" {
  description = "Privaet subnet ID"
}

variable "public_subnet_a_id" {
  description = "Public subnet A ID"
}

variable "public_subnet_b_id" {
  description = "Public subnet B ID"
}

variable "default_sg_id" {
  description = "Deafutl security group"
}

variable "service_name" {
  description = "Service name for service registry"
}

variable "sd_ns_name" {
  description = "Service registry DNS zone"
}
variable "key_name" {
  default = "dimaTest"
  description = "PEM file"
}

variable "rproxy_min_asg_size" {
  default = 1
  description = "Revere proxy asg min size"
}

variable "rproxy_max_asg_size" {
  default = 1
  description = "Revere proxy asg max size"
}

variable "desired_capacity" {
  default = 1
  description = "Desired capacity"
}
