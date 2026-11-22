variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "aws_profile" {
  type    = string
  default = "sahil"
}
variable "key_pair_name" {
  type = string
}
variable "private_key_path" {
  type = string
}
variable "ssh_allowed_cidr" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
