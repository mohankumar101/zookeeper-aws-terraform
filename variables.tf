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
