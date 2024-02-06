/* Replaced the bottom section of specifying invidual variable definitions into a map of objects, which can then be used for multiple deployments (Dev/QA/PROD releases) */

variable "serverconfig" {
    description = "Zookeeper EC2 instance configuration"
    type = map(object({
        zk-region = string
        zk_ec2_inst_type = string
        zk_inst_name = set(string)
        zk_ec2_key_name = string
        zk-subnets = list(string)
  }))

    default = {
        test = {
            zk-region = "us-west-2a"
            zk_ec2_inst_type = "t2.micro"
            zk_inst_name = ["member1", "member2"]
            zk_ec2_key_name = "avmk-newkeys"
            zk-subnets = ["10.0.1.0/24","10.0.2.0/24"]
        }
    }
}


/*
variable "zk-region" {
    type = string
    default = "us-west-2a"
}

variable "zk_ec2_inst_type" {
    description = "Zookeeper EC2 instance configuration"
    type = string
    default = "t2.micro"
}
variable "zk_ec2_key_name" {
    description = "Zookeeper SSH Keys"
    type = string
    default = "avmk-newkeys"
}
variable "zk-subnets" {
    description = "Zookeeper Subnets"
    type = list(string)
    default = ["10.0.1.0/24","10.0.2.0/24"]
}
*/
