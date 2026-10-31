resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "sahil-lambda-code-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "terraform-lambda-code"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "lambda_function.zip"
  source = data.archive_file.lambda_zip.output_path

  etag = filemd5(data.archive_file.lambda_zip.output_path)

}