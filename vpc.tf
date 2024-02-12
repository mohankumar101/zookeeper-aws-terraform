### enable_dns* arguments are to enable public IP for VPC instances, otherwise they will end up having a private IP only - inaccessible from internet 

resource "aws_vpc" "zk_test" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Zookeeper Test VPC"
  }
  enable_dns_hostnames = true
  enable_dns_support = true
}

### VAR-PROB1-SOLUTION - Instead of the avail_zone key from the variable, I used zk_subnets with the availability zone as a map 
resource "aws_subnet" "zk_public_subnet" {
  for_each = var.serverconfig.test.zk_subnets
    vpc_id     = aws_vpc.zk_test.id
    cidr_block = each.value
    availability_zone = each.key
    tags = {
      Name = "Zookeeper Public Subnet"
    }
}

### A route table for the VPC 
resource "aws_route_table" "public_routing_table" {
  vpc_id = aws_vpc.zk_test.id
  tags = {
    Name = "Zookeeper Test public access"
  }
}

### route table association for the VPC
resource "aws_route_table_association" "public" {
  for_each  = aws_subnet.zk_public_subnet
    subnet_id = each.value.id
    route_table_id = aws_route_table.public_routing_table.id
}

### Internet gateway - entrypoint for internet to reach EC2 machines 
resource "aws_internet_gateway" "zk_public_igw" {
  vpc_id = aws_vpc.zk_test.id
  tags = {
    Name = "Zookeeper Test public access Internet Gateway"
  }
}

### Route entry on the routing table, referring to the Internet gateway as route for internet (0.0.0.0/0) 
resource "aws_route" "public_internet_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.public_routing_table.id
  gateway_id = aws_internet_gateway.zk_public_igw.id
}
