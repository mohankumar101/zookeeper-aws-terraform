### Data block does lookup for AMI data, and find the matching AMI, this helps in avoiding hardcoded AMIs, outdated AMIs etc

data "aws_ami" "zk-ec2-amidata" {
  most_recent   = true
  owners        = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

### Iterating over the availability zones to create EC2 for each AZ

resource "aws_instance" "zk_ec2" {
    # for_each = var.serverconfig.test.zk_inst_name
    for_each = toset(var.serverconfig.test.zk_avail_zone)
        ami                         = data.aws_ami.zk-ec2-amidata.id
        instance_type               = var.serverconfig.test.zk_ec2_inst_type
        user_data                   = file("./setup-zookeeper.sh")
        key_name                    = var.serverconfig.test.zk_ec2_key_name
        vpc_security_group_ids      = [ aws_security_group.allow_ssh.id, aws_security_group.allow_zk_traffic.id ]
        subnet_id                   = aws_subnet.zk_public_subnet[each.value].id
        associate_public_ip_address = true
        tags = {
            Name = "Zookeeper EC2 - ${each.value}"
        }
}
