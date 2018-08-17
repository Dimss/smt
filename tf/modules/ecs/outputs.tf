output "service_discovery_service_arn" {
  value = "${aws_service_discovery_service.sd_service.arn}"
}

output "service_name" {
  value = "${var.service_name}"
}

output "sd_ns_name" {
  value = "${var.sd_dns_name}"
}