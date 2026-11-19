variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "ami_id" {
  type        = string
  description = "Valid AMI ID in the selected region"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "terraform-generated-key"
}

variable "subnet_id" {
  type        = string
  description = "Existing subnet ID"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Existing security group IDs"
}
