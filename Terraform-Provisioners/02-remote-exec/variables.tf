variable "aws_region" {
  type        = string
  description = "AWS region containing the default VPC and key pair"
  default     = "ap-south-1"
}
variable "aws_profile" {
  type        = string
  description = "AWS CLI profile; use null/empty if using environment credentials"
  default     = "sahil"
}
variable "key_pair_name" {
  type        = string
  description = "Existing EC2 key pair name in the selected region"
}
variable "private_key_path" {
  type        = string
  description = "Local path to the matching private key file"
}
variable "ssh_allowed_cidr" {
  type        = string
  description = "Your public IPv4 CIDR, normally x.x.x.x/32"
}
variable "instance_type" {
  type        = string
  default     = "t2.micro"
}
