variable "aws_profile" {
  description = "AWS CLI profile configured on your machine"
  type        = string
  default     = "sahil"
}

variable "mumbai_bucket_name" {
  description = "Globally unique S3 bucket name for ap-south-1"
  type        = string
}

variable "virginia_bucket_name" {
  description = "Globally unique S3 bucket name for us-east-1"
  type        = string
}
