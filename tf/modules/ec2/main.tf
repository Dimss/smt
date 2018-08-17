# Bastion EC2 instance in public network
resource "aws_instance" "bastion" {
  ami = "${var.ami}"
  instance_type = "${var.instace_type}"
  count = 1
  subnet_id = "${var.public_subnet_a_id}"
  key_name = "${var.key_name}"
  tags {
    Name = "stm-bastion-srv"
  }
}

## ELB for revers proxiyes
resource "aws_elb" "smt_rproxy_elb" {
  name = "rproxy-elb"
  "listener" {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }
  subnets = [
    "${var.public_subnet_a_id}",
    "${var.public_subnet_b_id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "smt-rproxy-elb"
  }
}


data "template_file" "user_data" {
  template = "${file("${path.module}/rproxy_user_data.tpl")}"
  vars {
    service_name = "${var.service_name}"
    sd_ns_name = "${var.sd_ns_name}"
  }
}


## Launch configuration for revers proxies servers
resource "aws_launch_configuration" "smt_rprorxy_launch_conf" {
  name = "smt-rproxylaunch-conf"
  image_id = "${var.ami}"
  instance_type = "${var.instace_type}"
  key_name = "${var.key_name}"
  user_data = "${data.template_file.user_data.rendered}"
  security_groups = [
    "${var.default_sg_id}"
  ]
}

## ASG for reverse proxies servers
resource "aws_autoscaling_group" "smt_rproxy_asg" {
  name = "rproxy-asg"
  max_size = "${var.rproxy_min_asg_size}"
  min_size = "${var.rproxy_max_asg_size}"
  desired_capacity = "${var.desired_capacity}"
  health_check_type = "ELB"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.smt_rprorxy_launch_conf.name}"
  load_balancers = [
    "${aws_elb.smt_rproxy_elb.name}"]
  vpc_zone_identifier = [
    "${var.private_subnet_a_id}",
    "${var.private_subnet_b_id}"]

  tag {
    key = "Name"
    value = "rproxy-group"
    propagate_at_launch = true
  }
}
