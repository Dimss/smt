provider "aws" {
  profile = "default"
  region = "${var.region}"
}


module "vpc" {
  source = "modules/vpc"
}

module "ec2" {
  source = "modules/ec2"
  public_subnet_a_id = "${module.vpc.public_subnet_a_id}"
  public_subnet_b_id = "${module.vpc.public_subnet_b_id}"
  private_subnet_a_id = "${module.vpc.private_subnet_a_id}"
  private_subnet_b_id = "${module.vpc.private_subnet_b_id}"
  default_sg_id = "${module.vpc.default_sg_id}"
  service_name = "${module.ecs.service_name}"
  sd_ns_name = "${module.ecs.sd_ns_name}"
}

module "ecs" {
  source = "modules/ecs"
  vpc_id = "${module.vpc.vpc_id}"
}


