variable "vpc_id" {
  default = "vpc-02ee46f22955a5b81"
}

variable "ig_id" {
  default = "igw-08bc9b3838ff3ddf3"
}

variable "ami_id" {
  # default = "ami-03b715834d64be8c0"
  default = "ami-055c1755b888344f7"
}

variable "user_data" {
  description = "user data"
  type        = "string"
  default     = ""
}
