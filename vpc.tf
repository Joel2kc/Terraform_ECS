resource "aws_vpc" "terraform-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_internet_gateway" "terraform-gw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_nat_gateway" "terraform-nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.private-subnet.id

  tags = {
    Name = var.nat_gateway_name
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.terraform-gw]
}


resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "private-subnet"
  }
}

#resource "aws_route" "r" {
 # route_table_id            = aws_route_table.private.id
  #destination_cidr_block    = "0.0.0.0/0"
  #gateway_id                = aws_internet_gateway.terraform-gw.id
#}

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-gw.id
  }

  tags = {
    Name = "RouteTable"
  }
}

resource "aws_route_table_association" "Public-rt" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_route_table_association" "Private-rt" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.route-table.id
}