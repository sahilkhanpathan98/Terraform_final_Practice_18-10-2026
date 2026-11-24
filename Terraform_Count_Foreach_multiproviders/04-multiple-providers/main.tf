# This resource uses the default AWS provider (Mumbai).
resource "aws_s3_bucket" "mumbai" {
  bucket = var.mumbai_bucket_name

  tags = {
    Name        = "day66-mumbai-practice"
    Environment = "practice"
    Region      = "ap-south-1"
  }
}

# This resource explicitly uses the aliased AWS provider (Virginia).
resource "aws_s3_bucket" "virginia" {
  provider = aws.virginia
  bucket   = var.virginia_bucket_name

  tags = {
    Name        = "day66-virginia-practice"
    Environment = "practice"
    Region      = "us-east-1"
  }
}
