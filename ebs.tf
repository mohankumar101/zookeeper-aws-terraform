### EBS Volume for zookeeper instances - total of 3 volumes in their respective AZs
resource "aws_ebs_volume" "zk_data_volume" {
  for_each = toset(var.serverconfig.test.zk_avail_zone)
    availability_zone = each.value
    size              = 1
}

/* Attaching EBS volume to their respective EC2 instances in their availability zones. Here, a conditional statement is used
Here is how to understand this;
            for_each    - iterates over the volume's availability zone name (3 volumes in this example for each AZ) that are created from EBS volume creation section
            volume_id   - can be identified by supplying the AZ name as [each.key].id using aws_ebs_volume.zk_data_volume data
            instance_id - Read this as below
              It needs AWS instance ID, which comes from aws_instance.zk_ec2[each.key].id - where each.key is the availability zone of EC2
              To figure out the EC2 and EBS in a specific AZ, it uses the conditional statement 
                - each.value.availabilty_zone - refers to the volume's AZ
                - aws_instance.zk_ec2[each.key].availability_zone - refers to the AZ of the EC2
                - each.value.availability_zone == aws_instance.zk_ec2[each.key].availability_zone ? - Expression matches them, and if they match, it assigns instance_id to aws_instance.zk_ec2[each.key].id
                - If it doesn't match, it assigns null
*/

resource "aws_volume_attachment" "ebs_attachment" {
  for_each = aws_ebs_volume.zk_data_volume
    device_name = "/dev/xvdh"
    volume_id   = aws_ebs_volume.zk_data_volume[each.key].id
    instance_id = each.value.availability_zone == aws_instance.zk_ec2[each.key].availability_zone ? aws_instance.zk_ec2[each.key].id : null
}


