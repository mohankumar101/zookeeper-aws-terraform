output "vpc_id" {
    description = "Zookeeper VPC ID"
    value = aws_vpc.zk_test.id
}

output "instance_private_ip" {
    description = "Zookeeper EC2 instance Public IP"
    value = [ for ec2_instance in aws_instance.zk_ec2: ec2_instance.private_ip ]
}

output "instance_private_dns_map" {
    description = "Zookeeper EC2 instance Public DNS"
    value = { for ec2_instance in aws_instance.zk_ec2: ec2_instance.id => ec2_instance.public_dns }
}

output "entire_ec2_data" {
    description = "All the EC2 instance data"
    value = aws_instance.zk_ec2
}

output "EBS" {
  value = aws_ebs_volume.zk_data_volume
}