# Call only EC2 by keeping only this module block.
module "ec2" {
  source = "../Modules/EC2"

  ami_id        = "ami-xxxxxxxxxxxxxxxxx"
  instance_type = "t2.micro"
}

# To create S3 too, uncomment this module block and set a unique bucket name.
# module "s3" {
#   source = "../Modules/S3"
#
#   bucket_name = "replace-with-a-globally-unique-bucket-name"
# }
