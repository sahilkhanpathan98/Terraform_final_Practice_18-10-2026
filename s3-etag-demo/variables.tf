variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "ssh_cidr" {
  type = string
}