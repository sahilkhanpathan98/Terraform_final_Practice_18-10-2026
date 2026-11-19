variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "existing_key_name" {
  type        = string
  description = "Exact name of an existing Key Pair in this AWS region"
}

variable "ami_id" {
  type        = string
  description = "Valid AMI ID in the selected region"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnet_id" {
  type        = string
  description = "Existing subnet ID"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Existing security group IDs"
}
