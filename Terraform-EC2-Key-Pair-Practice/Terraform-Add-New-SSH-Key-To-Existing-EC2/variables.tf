variable "aws_region" {
  description = "AWS region where the EC2 key pair will be registered"
  type        = string
  default     = "ap-south-1"
}

variable "key_name" {
  description = "Unique name for the new AWS EC2 key pair"
  type        = string
}

variable "ec2_public_ip" {
  description = "Public IP (or reachable IP) of the existing Linux EC2 instance"
  type        = string
}

variable "ssh_user" {
  description = "Linux username on the existing EC2 instance"
  type        = string
}

variable "old_private_key_path" {
  description = "Full local path to the old private key that currently accesses the EC2"
  type        = string
  sensitive   = true
}

variable "new_private_key_path" {
  description = "Full local path where you intend to save the new private key after apply"
  type        = string
}
