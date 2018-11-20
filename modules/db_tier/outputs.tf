output db_instance {
  description = "the db instance that is created"
  value = "${aws_instance.db-eu-west-1a.private_ip}"
}
