resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "combined-module-ec2"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}
