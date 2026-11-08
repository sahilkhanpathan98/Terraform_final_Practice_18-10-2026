module "ec2-module" {

  source = "git::https://github.com/sahilkhanpathan98/Terraformpractice.git//Day7-Module-source-directory?ref=main"

  ami_id        = "ami-xxxxxxxx"
  instance_type = "t2.micro"
}