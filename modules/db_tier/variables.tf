variable "vpc_id" {
  default = "vpc-02ee46f22955a5b81"
}

variable "ig_id" {
  default = "igw-08bc9b3838ff3ddf3"
}

variable "ami_id" {
  default = "ami-052d4b45126cc68ec"
}

variable "user_data" {
  description = "user data"
  default = ""
}
