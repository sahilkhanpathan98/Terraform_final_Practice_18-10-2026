terraform {
  backend "s3" {
    bucket       = "mehuna"
    key          = "terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}