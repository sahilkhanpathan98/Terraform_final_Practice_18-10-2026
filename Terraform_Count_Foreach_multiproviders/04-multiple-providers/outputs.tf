output "mumbai_bucket_name" {
  description = "S3 bucket managed by the default Mumbai provider"
  value       = aws_s3_bucket.mumbai.bucket
}

output "virginia_bucket_name" {
  description = "S3 bucket managed by the aliased Virginia provider"
  value       = aws_s3_bucket.virginia.bucket
}
