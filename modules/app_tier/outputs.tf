output security_group_id {
  description = "the id of the app security group"
  value = "${aws_security_group.app_security_group.id}"
}

output subnet_id_1a {
  description = "the app subnet"
  value = "${aws_subnet.app-eu-west-1a.id}"
}
output subnet_cidr_block_1a {
  description = "the cidr block of the app subnet"
  value = "${aws_subnet.app-eu-west-1a.cidr_block}"
}

output subnet_id_1b {
  description = "the app subnet"
  value = "${aws_subnet.app-eu-west-1b.id}"
}
output subnet_cidr_block_1b {
  description = "the cidr block of the app subnet"
  value = "${aws_subnet.app-eu-west-1b.cidr_block}"
}

output subnet_id_1c {
  description = "the app subnet"
  value = "${aws_subnet.app-eu-west-1c.id}"
}
output subnet_cidr_block_1c {
  description = "the cidr block of the app subnet"
  value = "${aws_subnet.app-eu-west-1c.cidr_block}"
}

output ig_id {
  description = "the cidr block of the app subnet"
  value = "${var.ig_id}"
}

output security_group {
  description = "Security group for instances"
  value = "${aws_security_group.app_security_group.id}"
}

output user_data {
  description = "user data for launch configuaration"
  value = "${var.user_data}"
}
