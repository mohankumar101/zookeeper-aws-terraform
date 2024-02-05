resource "aws_vpc" "zk-test" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Zookeeper Test VPC"
  }
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "zk-public-subnet" {
  vpc_id     = aws_vpc.zk-test.id
  cidr_block = var.zk-subnets[0]
  availability_zone = var.zk-region
  tags = {
    Name = "Zookeeper Public Subnet"
  }
}

resource "aws_subnet" "zk-private-subnet" {
  vpc_id     = aws_vpc.zk-test.id
  cidr_block = var.zk-subnets[1]
  availability_zone = var.zk-region
  tags = {
    Name = "Zookeeper Private Subnet"
  }
}

resource "aws_route_table" "public-routing-table" {
  vpc_id = aws_vpc.zk-test.id
  tags = {
    Name = "Zookeeper Test public access"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.zk-public-subnet.id
  route_table_id = aws_route_table.public-routing-table.id
}

resource "aws_internet_gateway" "zk-public-igw" {
  vpc_id = aws_vpc.zk-test.id
  tags = {
    Name = "Zookeeper Test public access Internet Gateway"
  }
}

resource "aws_route" "public-internet-route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.public-routing-table.id
  gateway_id = aws_internet_gateway.zk-public-igw.id
}
