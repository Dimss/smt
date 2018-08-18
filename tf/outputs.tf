output "sd_service_arn" {
  value = "${module.ecs.service_discovery_service_arn}"
}
output "private_subnest" {
  value = [
    "${module.vpc.private_subnet_a_id}",
    "${module.vpc.private_subnet_b_id}"]
}

output "security_group" {
  value = "${module.vpc.default_sg_id}"
}

// Disabled - use for deubg only
//output "nginx_conf_rendered" {
//  value = "${module.ec2.nginx_rendered}"
//}

output "helloworld_elb" {
  value = "${module.ec2.helloworld_elb}"
}