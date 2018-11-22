# Terraform: Blue-Green Deployment

### Description:
Our task was to use terraform and AWS to set up load balanced and autoscaled 2-tier architecture for a node app application - it also had to be 'highly available', meaning that it has redundancies across all availability zones. After this, we then had to implement a blue-green deployment system on this architecture - this makes it so that we can update the underlying application dynamically and with as little downtime as possible.

### Work Log:
1. Created the base terraform architecture:
```
mkdir project_name
cd project_name
mkdir modules scripts
mkdir modules/app_tier modules/db_tier
mkdir scripts/app scripts/db
touch main.tf variables.tf
touch modules/app_tier/main.tf modules/app_tier/outputs.tf modules/app_tier/variables.tf
touch modules/db_tier/main.tf modules/db_tier/outputs.tf modules/db_tier/variables.tf
touch scripts/app/init.sh.tpl
touch scripts/db/init.sh.tpl
```
Run ```terraform init``` in the command line to initialise terraform.

2. We first added all the required code into the module terraform files in order to create four different subnets in inside a VPC that we had previously created. Three of these subnets were public and in different availability zones (created in main.tf in app_tier) and the final subnet was private (created in main.tf in db_tier). The three public subnets are for our app, and the private subnet will be used for our database. This is an example of one of the public subnets:
```
  resource "aws_subnet" "app-eu-west-1a" {
    vpc_id                  = "${var.vpc_id}"
    cidr_block              = "10.0.201.0/24"
    availability_zone       = "eu-west-1a"
    map_public_ip_on_launch = true
    tags {
      Name                  = "subnet_1a"
    }
  }
```

3. Next, we created security groups, a route table and route table associations for both the app and the database inside the main.tf file in app_tier and db_tier respectively. We then linked these with the corresponding subnets. This is the code for the app security group:
```
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
```
**Note:** the 'ingress' and 'egress' blocks are the inbound and outbound rules on AWS. You can set these to whatever you like.

4. We now began to add to the outputs.tf files in the modules. This file is designed to export the variables that are defined inside it towards the master main.tf file outside of the modules, so that it can use them. An example of one of the outputs that we used were in the app_tier outputs.tf file:
```
  output security_group_id {
    description = "the id of the app security group"
    value       = "${aws_security_group.app_security_group.id}"
  }
```

5. Finally for the modules, we now added to the variables.tf file in both app_tier and db_tier. The variables that we define in here are to be used in the module main.tf files within app_tier and db_tier. An example of some of the variable definitions that we did inside these files:
```
  variable "vpc_id" {
    default = "vpc-02ee46f22955a5b81"
  }

  variable "ig_id" {
    default = "igw-08bc9b3838ff3ddf3"
  }

  variable "ami_id" {
    default = "ami-03b715834d64be8c0"
  }
```

6. Next, we moved on to the scripts folder. Inside scripts/app and scripts/db, we modified the init.sh.tpl files so that it would correctly run the app when an instance of the app AMI is created. For the init.sh.tpl file for the app, we added the following code:
```
  #! /bin/bash

  cd /home/ubuntu/app

  pm2 start app.js
```
**Note:** Each line of this is run inside the command line in the virtual machine that is created by the AMI in AWS. Thus, this enters the app folder and then starts app.js in the virtual machine, which causes the app to display in browser.

7. We now turned to the master main.tf file (outside the modules). This is where we include load balancers, autoscaling groups and link together the scripts and modules. We first linked it to AWS at the top of the page:
```
  provider "aws" {
    region                  = "eu-west-1"
  }
```

8. Still in this main.tf file, we now linked the app and db scripts by putting them into data variables. We also set up an environment variable called db_host for the app, which we can use to access mongodb from the app:
```
  data "template_file" "app_init" {
    template                = "${file("./scripts/app/init.sh.tpl")}"
    vars {
      db_host               = "mongodb://${module.db.db_instance}:27017/posts"
    }
  }

  data "template_file" "db_init" {
    template                = "${file("./scripts/db/init.sh.tpl")}"
  }
```

9. At the bottom of the main.tf file, we now provided the link between this file and the modules. The following code sends the specified variables into the app_tier and db_tier modules, which we can then use inside the modules:
```
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
```

10. Finally for the base terraform file, we added to the master variables.tf file (outside of the modules folder). In this file, we define variables to use inside the master main.tf file - this is what we added to our variables.tf file:
```
  variable "vpc_id" {
    default = "vpc-02ee46f22955a5b81"
  }

  variable "app_ami_id" {
    default = "ami-03b715834d64be8c0"
  }

  variable "db_ami_id" {
    default = "ami-052d4b45126cc68ec"
  }

  variable "ig_id" {
    default = "igw-08bc9b3838ff3ddf3"
  }
```

11. We now turned our attention to blue-green deployment.
