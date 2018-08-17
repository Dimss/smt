# VPC
resource "aws_vpc" "smt_vpc" {
  cidr_block = "${var.vpc_cidr}"
  tags = "${var.vpc_tags}"
  enable_dns_support = true
  enable_dns_hostnames = true
}


## Internet and NAT gateways
resource "aws_internet_gateway" "smt_igw" {
  vpc_id = "${aws_vpc.smt_vpc.id}"
  tags {
    Name = "SMT-IGW"
  }
}

resource "aws_eip" "nat_gw_a_eip" {}
resource "aws_eip" "nat_gw_b_eip" {}

resource "aws_nat_gateway" "smt_nat_gw_a" {
  allocation_id = "${aws_eip.nat_gw_a_eip.id}"
  subnet_id = "${aws_subnet.public_subnet_a.id}"
}

resource "aws_nat_gateway" "smt_nat_gw_b" {
  allocation_id = "${aws_eip.nat_gw_b_eip.id}"
  subnet_id = "${aws_subnet.public_subnet_b.id}"
}

## Private and Public suntes
resource "aws_subnet" "private_subnet_a" {
  cidr_block = "${var.private_subnnet_a}"
  vpc_id = "${aws_vpc.smt_vpc.id}"
  availability_zone = "${var.private_subnet_a_az}"
  map_public_ip_on_launch = false
  tags {
    Name = "smt-private-subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  cidr_block = "${var.private_subnnet_b}"
  availability_zone = "${var.private_subnet_b_az}"
  vpc_id = "${aws_vpc.smt_vpc.id}"
  map_public_ip_on_launch = false
  tags {
    Name = "smt-private-subnet_b"
  }
}

resource "aws_subnet" "public_subnet_a" {
  cidr_block = "${var.public_subnet_a}"
  availability_zone = "${var.public_subnet_a_az}"
  vpc_id = "${aws_vpc.smt_vpc.id}"
  map_public_ip_on_launch = true
  tags {
    Name = "smt-public-subnet_a"
  }
}
resource "aws_subnet" "public_subnet_b" {
  cidr_block = "${var.public_subnet_b}"
  availability_zone = "${var.public_subnet_b_az}"
  vpc_id = "${aws_vpc.smt_vpc.id}"
  map_public_ip_on_launch = true
  tags {
    Name = "smt-public-subnet_b"
  }
}

## Privaet and public route tables
resource "aws_route_table" "private_route_table_a" {
  vpc_id = "${aws_vpc.smt_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.smt_nat_gw_a.id}"
  }
  tags {
    Name = "private-route-table_a"
  }
}
resource "aws_route_table" "private_route_table_b" {
  vpc_id = "${aws_vpc.smt_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.smt_nat_gw_b.id}"
  }
  tags {
    Name = "private-route-table_b"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.smt_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.smt_igw.id}"
  }
  tags {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "private_route_to_private_network_a" {
  subnet_id = "${aws_subnet.private_subnet_a.id}"
  route_table_id = "${aws_route_table.private_route_table_a.id}"
}

resource "aws_route_table_association" "private_route_to_private_network_b" {
  subnet_id = "${aws_subnet.private_subnet_b.id}"
  route_table_id = "${aws_route_table.private_route_table_b.id}"
}

resource "aws_route_table_association" "public_route_to_public_network_a" {
  subnet_id = "${aws_subnet.public_subnet_a.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public_route_to_public_network_b" {
  subnet_id = "${aws_subnet.public_subnet_b.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

# SGs
resource "aws_security_group_rule" "allow-ssh" {
  from_port = 22
  protocol = "tcp"
  security_group_id = "${aws_vpc.smt_vpc.default_security_group_id}"
  to_port = 22
  type = "ingress"
  cidr_blocks = [
    "89.138.247.223/32"]
}

resource "aws_security_group_rule" "allow-web" {
  from_port = 80
  protocol = "tcp"
  security_group_id = "${aws_vpc.smt_vpc.default_security_group_id}"
  to_port = 80
  type = "ingress"
  cidr_blocks = [
    "89.138.247.223/32"]
}

resource "aws_security_group_rule" "allow-ssl" {
  from_port = 443
  protocol = "tcp"
  security_group_id = "${aws_vpc.smt_vpc.default_security_group_id}"
  to_port = 443
  type = "ingress"
  cidr_blocks = [
    "89.138.247.223/32"]
}

resource "aws_security_group_rule" "allow-web-app" {
  from_port = 8080
  protocol = "tcp"
  security_group_id = "${aws_vpc.smt_vpc.default_security_group_id}"
  to_port = 8080
  type = "ingress"
  cidr_blocks = [
    "89.138.247.223/32"]
}
