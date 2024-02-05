resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.zk-test.id

  ingress {
    description = "Allow SSH connections from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all connections to everywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_SSH SG group"
  }
}

### VPC's Zookeeper traffic security group

data "aws_vpc" "zk-test" {
  id = aws_vpc.zk-test.id
}

variable "zk-ingressports" {
    type = list(number)
    default = [2181,2888,3888]
}
variable "zk-egressports" {
    type = list(number)
    default = [2181,2888,3888]
}


resource "aws_security_group" "allow_zk_traffic" {
  name        = "allow_zk_traffic"
  description = "Allow Zookeeper inbound/outbound traffic"
  vpc_id      = aws_vpc.zk-test.id
  dynamic "ingress" {
        /* What happens below is explained here. 
        Iterator is a variable name to carry the value being read. For each value in the variable ingressrules' list its read and assigned to port. 
        Its then used with port.value to be used in the code 
        */
        iterator = port
        for_each = var.zk-ingressports
        content {
        from_port = port.value
        to_port =  port.value
        protocol = "TCP"
        cidr_blocks = data.aws_vpc.zk-test.cidr_block_associations[*].cidr_block
        }
    }
  dynamic "egress" {
        /* What happens below is explained here. 
        Iterator is a variable name to carry the value being read. For each value in the variable ingressrules' list its read and assigned to port. 
        Its then used with port.value to be used in the code 
        */
        iterator = port
        for_each = var.zk-egressports
        content {
        from_port = port.value
        to_port =  port.value
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }
  
  tags = {
    Name = "Allow ZK traffic SG group"
  }
}
