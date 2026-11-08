module "app" {
  source = "../Source-Directory"

  ami_id        = "ami-xxxxxxxxxxxxxxxxx"
  instance_type = "t2.micro"
  bucket_name   = "replace-with-a-globally-unique-bucket-name"
}
