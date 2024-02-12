output "vpc_id" {
    description = "Zookeeper VPC ID"
    value = aws_vpc.zk_test.id
}

output "instance_public_dns_list" {
    description = "Zookeeper EC2 instance Public DNS"
    value = [ for ec2_instance in aws_instance.zk_ec2: ec2_instance.public_dns ]
}

output "instance_public_dns_map" {
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