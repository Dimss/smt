variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "Default private VPC CIDR"
}

variable "private_subnnet_a" {
  default = "10.0.0.0/24"
  description = "Private subnet"
}

variable "private_subnnet_b" {
  default = "10.0.1.0/24"
  description = "Private subnet"
}

variable "public_subnet_a" {
  default = "10.0.2.0/24"
  description = "Public subnet A"
}

variable "public_subnet_b" {
  default = "10.0.3.0/24"
  description = "Public subnet B"
}

variable "private_subnet_a_az" {
  default = "eu-west-1a"
  description = "AZ for private subnet A"
}

variable "private_subnet_b_az" {
  default = "eu-west-1b"
  description = "AZ for private subnet B"
}

variable "public_subnet_a_az" {
  default = "eu-west-1a"
  description = "AZ for public subnet A"
}

variable "public_subnet_b_az" {
  default = "eu-west-1b"
  description = "AZ for public subnet B"
}

variable "vpc_tags" {
  type = "map"
  default = {
    "Name" = "SMT"
  }
}

