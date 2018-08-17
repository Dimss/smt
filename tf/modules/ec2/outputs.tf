output "nginx_rendered" {
  value = "${data.template_file.user_data.rendered}"
}

output "helloworld_elb" {
  value = "${aws_elb.smt_rproxy_elb.dns_name}"
}