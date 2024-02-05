output "vpc_id" {
    description = "Zookeeper VPC ID"
    value = aws_vpc.zk-test.id
}

output "instance_public_dns" {
    description = "Zookeeper EC2 instance Public DNS"
    value = aws_instance.zk_ec2.public_dns
}

output "instance_public_ip" {
    description = "Zookeeper EC2 instance Public IP"
    value = aws_instance.zk_ec2.public_ip
}
