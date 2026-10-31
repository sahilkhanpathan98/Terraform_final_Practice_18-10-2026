variable "ami_id" {
  default = "ami-05fa46471b02db0ce"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}