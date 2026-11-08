module "ec2_instance" {

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name          = "registry-ec2"
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  subnet_id = "subnet-xxxxxxxx"

  tags = {
    Name        = "Registry-EC2"
    Environment = "dev"
  }
}