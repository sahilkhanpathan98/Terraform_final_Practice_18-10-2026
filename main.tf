


resource "aws_vpc" "cust_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "cust-vpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.cust_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "cust_ig" {
  vpc_id = aws_vpc.cust_vpc.id

  tags = {
    Name = "cust-IG"
  }
}


resource "aws_route_table" "cust_rt" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cust_ig.id
  }

  tags = {
    Name = "cust-RT"
  }
}
