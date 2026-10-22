variable "ami_id" {
  description = "Amazon Linux 2023 x86_64 AMI ID for ap-south-1"
  type        = string
  default     = "ami-088fb12f8e8397f06"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name in ap-south-1"
  type        = string
  default     = "Final-keypairs"
}

variable "ssh_allowed_cidr" {
  description = "Your trusted public IPv4 address in CIDR format, for example 203.0.113.10/32"
  type        = string
}
