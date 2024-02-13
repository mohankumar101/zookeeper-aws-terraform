# zookeeper-aws-terraform
To deploy zookeeper service on AWS using terraform
In this example I am trying to cover all the Terraform major concepts (meta arguments, loops, user_data).

Here:
 - Deployed EC2 in multiple AZs
 - Created EBS blocks
 - Mapped the EBS blocks with respective EC2 instance, using a conditional check
 - Dynamic blocks for security group ports
 - User data to provision machines with zookeeper setup process

Improvement plans:
- Code could automatically resolve AZs from a region (using data blocks), for high availability without us hardcoding AZs

Will continue to improve it, as and when I get time.

Should you need any help or for feedback, feel free to write to mohankumar101@gmail.com
