provider "aws" {
  region                  = "eu-west-1"
}

# =========================== INTERNET GATEWAY ===========================
# INTERNET GATEWAY IS ALREADY ATTACHED, HENCE COMMENTED OUT CODE

# resource "aws_internet_gateway" "default" {
#   vpc_id                  = "${var.vpc_id}"
#   # internet_gateway_id  = "${module.app.ig_id}"
#   tags {
#     Name                  = "Internet Gateway"
#   }
# }

# =========================== TEMPLATE FILES ===========================

data "template_file" "app_init" {
  template                = "${file("./scripts/app/init.sh.tpl")}"
  vars {
    db_host               = "mongodb://${module.db.db_instance}:27017/posts"
  }
}

data "template_file" "db_init" {
  template                = "${file("./scripts/db/init.sh.tpl")}"
}

# =========================== LOAD BALANCER ===========================

resource "aws_lb" "lb" {
  name                    = "lb"
  internal                = false
  load_balancer_type      = "network"
  subnets                 = ["${module.app.subnet_id_1a}", "${module.app.subnet_id_1b}", "${module.app.subnet_id_1c}"]

  enable_deletion_protection = false

  tags {
    Environment           = "production"
  }
}

# =========================== LAUNCH CONFIGURATION ===========================

resource "aws_launch_configuration" "launch_config" {
  image_id                = "${var.app_ami_id}"
  instance_type           = "t2.micro"
  user_data               = "${data.template_file.app_init.rendered}"
  key_name                = "DevOpsStudents"
  security_groups         = ["${module.app.security_group}"]
  user_data               = "${base64encode(module.app.user_data)}"

  lifecycle {
    create_before_destroy   = true
  }
}

# =========================== LAUNCH TEMPLATE ===========================

resource "aws_launch_template" "launch_template" {
  image_id                = "${var.app_ami_id}"
  instance_type           = "t2.micro"
  key_name                = "DevOpsStudents"
  vpc_security_group_ids  = ["${module.app.security_group}"]
  user_data               = "${base64encode(module.app.user_data)}"
}

# =========================== AUTOSCALING GROUP ===========================

resource "aws_autoscaling_group" "autoscaling_group" {
  name                    = "autoscaling_group - ${aws_launch_configuration.launch_config.name}"
  availability_zones      = ["eu-west-1a","eu-west-1b","eu-west-1c"]
  vpc_zone_identifier     = ["${module.app.subnet_id_1a}", "${module.app.subnet_id_1b}", "${module.app.subnet_id_1c}"]
  desired_capacity        = 2
  max_size                = 4
  min_size                = 1
  health_check_grace_period = 300
  health_check_type       = "EC2"
  termination_policies    = ["OldestInstance" , "Default"]
  wait_for_elb_capacity   = 2

  launch_template = {
    id                    = "${aws_launch_template.launch_template.id}"
    version               = "$$Latest"
  }

  tags = [{
    key                   = "Name"
    value                 = "DevOps-instance"
    propagate_at_launch   = true
    }]

    lifecycle {
      create_before_destroy   = true
    }
  }

resource "aws_autoscaling_attachment" "autoscaling_attachment" {
  alb_target_group_arn   = "${aws_lb_target_group.target_group.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.autoscaling_group.id}"
}

resource "aws_autoscaling_policy" "bat" {
  name                   = "foobar3-terraform-test"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = "${aws_autoscaling_group.autoscaling_group.name}"
}

  # =========================== LB TARGET GROUP ===========================

  resource "aws_lb_target_group" "target_group" {
    name = "target-group"
    port = 80
    protocol = "TCP"
    vpc_id = "${var.vpc_id}"
    stickiness {
      type = "lb_cookie"
      enabled = false
    }
  }

  # =========================== LB TARGET GROUP ATTACHMENT ===========================


  # resource "aws_lb_target_group_attachment" "target_attach" {
  #   target_group_arn = "${aws_lb_target_group.target_group.arn}"
  #   target_id       = "${aws_launch_template.launch_template.id}"
  #   port             = 80
  # }

  # =========================== LB LISTENER ===========================

  resource "aws_alb_listener" "listener" {
    load_balancer_arn = "${aws_lb.lb.arn}"
    port              = "80"
    protocol          = "TCP"
    default_action {
      target_group_arn = "${aws_lb_target_group.target_group.arn}"
      type             = "forward"
    }
  }

  # =========================== MODULES ===========================

  module "app" {
    source                  = "./modules/app_tier"
    vpc_id                  = "${var.vpc_id}"
    ami_id                  = "${var.app_ami_id}"
    ig_id                   = "${var.ig_id}"
    user_data               = "${data.template_file.app_init.rendered}"
  }

  module "db" {
    source                  = "./modules/db_tier"
    vpc_id                  = "${var.vpc_id}"
    ami_id                  = "${var.db_ami_id}"
    ig_id                   = "${var.ig_id}"
    user_data               = "${data.template_file.db_init.rendered}"
  }
