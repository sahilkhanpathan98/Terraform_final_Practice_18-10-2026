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
variable "http_allowed_cidr" {
  type        = string
  description = "Use your public IP/32 for a private demo, or 0.0.0.0/0 only if you intentionally want a public demo website."
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
