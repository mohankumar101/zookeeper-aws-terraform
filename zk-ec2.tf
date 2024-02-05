data "aws_ami" "zk-ec2-amidata" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "zk_ec2" {
  ami           = data.aws_ami.zk-ec2-amidata.id
  instance_type = var.zk_ec2_inst_type
  user_data     = ""
  key_name      = var.zk_ec2_key_name
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id, aws_security_group.allow_zk_traffic.id ]
  subnet_id = aws_subnet.zk-public-subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "Zookeeper EC2 Member"
  }
}
