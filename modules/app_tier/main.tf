
# =========================== INSTANCES ===========================
# resource "aws_instance" "app-eu-west-1a" {
#   ami                     = "${var.ami_id}"
#   subnet_id               = "${aws_subnet.app-eu-west-1a.id}"
#   instance_type           = "t2.micro"
#   vpc_security_group_ids  = ["${aws_security_group.app_security_group.id}"]
#   user_data               = "${var.user_data}"
#   key_name                = "DevOpsStudents"
#   tags {
#     Name                  = "app_1a"
#   }
# }
# resource "aws_instance" "app-eu-west-1b" {
#   ami                     = "${var.ami_id}"
#   subnet_id               = "${aws_subnet.app-eu-west-1b.id}"
#   instance_type           = "t2.micro"
#   vpc_security_group_ids  = ["${aws_security_group.app_security_group.id}"]
#   user_data               = "${var.user_data}"
#   key_name                = "DevOpsStudents"
#   tags {
#     Name                  = "app_1b"
#   }
# }
# resource "aws_instance" "app-eu-west-1c" {
#   ami                     = "${var.ami_id}"
#   subnet_id               = "${aws_subnet.app-eu-west-1c.id}"
#   instance_type           = "t2.micro"
#   vpc_security_group_ids  = ["${aws_security_group.app_security_group.id}"]
#   user_data               = "${var.user_data}"
#   key_name                = "DevOpsStudents"
#   tags {
#     Name                  = "app_1c"
#   }
# }
# =========================== SUBNETS ===========================
resource "aws_subnet" "app-eu-west-1a" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "10.0.201.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags {
    Name                  = "subnet_1a"
  }
}
resource "aws_subnet" "app-eu-west-1b" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "10.0.202.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true
  tags {
    Name                  = "subnet_1b"
  }
}
resource "aws_subnet" "app-eu-west-1c" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "10.0.203.0/24"
  availability_zone       = "eu-west-1c"
  map_public_ip_on_launch = true
  tags {
    Name                  = "subnet_1c"
  }
}

# =========================== SECURITY GROUPS ===========================

resource "aws_security_group" "app_security_group" {
  name                    = "app_security_group_DevOps"
  description             = "Inbound and outbound rules for the VPC of node application"
  vpc_id                  = "${var.vpc_id}"
  ingress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  ingress {
    from_port             = 22
    to_port               = 22
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  tags {
    Name                  = "app_security_group_DevOps"
  }
}

# =========================== ROUTE TABLES ===========================

resource "aws_route_table" "route_table" {
  vpc_id                  = "${var.vpc_id}"
  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = "${var.ig_id}"
  }
  tags {
    Name                  = "app_route_table_DevOps"
  }
}

# =========================== ROUTE TABLE ASSOCIATIONS ===========================

resource "aws_route_table_association" "app-association-1a" {
  subnet_id               = "${aws_subnet.app-eu-west-1a.id}"
  route_table_id          = "${aws_route_table.route_table.id}"
}
resource "aws_route_table_association" "app-association-1b" {
  subnet_id               = "${aws_subnet.app-eu-west-1b.id}"
  route_table_id          = "${aws_route_table.route_table.id}"
}
resource "aws_route_table_association" "app-association-1c" {
  subnet_id               = "${aws_subnet.app-eu-west-1c.id}"
  route_table_id          = "${aws_route_table.route_table.id}"
}
