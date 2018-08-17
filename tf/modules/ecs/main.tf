resource "aws_ecs_cluster" "smt_ecs_cluster" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_service_discovery_private_dns_namespace" "smt_ecs_private_dsn_ns" {
  name = "${var.sd_dns_name}"
  description = "ECS smt private DNS ns"
  vpc = "${var.vpc_id}"
}

resource "aws_service_discovery_service" "sd_service" {
  name = "${var.service_name}"
  dns_config {
    "dns_records" {
      ttl = 10
      type = "A"
    }
    namespace_id = "${aws_service_discovery_private_dns_namespace.smt_ecs_private_dsn_ns.id}"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

}