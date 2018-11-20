
# =========================== INSTANCES ===========================

resource "aws_instance" "db-eu-west-1a" {
  ami                     = "${var.ami_id}"
  subnet_id               = "${aws_subnet.db.id}"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = ["${aws_security_group.db_security_group.id}"]
  user_data               = "${var.user_data}"
  key_name                = "DevOpsStudents"
  tags {
    Name                  = "db_instance_DevOps"
  }
}

# =========================== SUBNETS ===========================

resource "aws_subnet" "db" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "10.0.210.0/24"
  map_public_ip_on_launch = true
  tags {
    Name                  = "db-subnet_DevOps"
  }
}

# =========================== SECURITY GROUPS ===========================

resource "aws_security_group" "db_security_group" {
  name                    = "db_security_group_DevOps"
  description             = "Inbound and outbound rules for the db of Kash"
  vpc_id                  = "${var.vpc_id}"
  ingress {
    from_port             = 27017
    to_port               = 27017
    protocol              = "tcp"
    cidr_blocks           = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
  }
  ingress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
  }
  ingress {
    from_port             = 1024
    to_port               = 65535
    protocol              = "tcp"
    cidr_blocks           = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
  }
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  tags {
    Name                  = "db_security_group_DevOps"
  }
}

# =========================== ROUTE TABLES ===========================

resource "aws_route_table" "db_route_table" {
  vpc_id                  = "${var.vpc_id}"
  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = "${var.ig_id}"
  }
  tags {
    Name                  = "db_route_table_DevOps"
  }
}

# =========================== ROUTE TABLE ASSOCIATIONS ===========================

resource "aws_route_table_association" "db-association" {
  subnet_id               = "${aws_subnet.db.id}"
  route_table_id          = "${aws_route_table.db_route_table.id}"
}
