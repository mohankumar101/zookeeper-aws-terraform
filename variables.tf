
/* VAR-PROB1 - The variable subnets have a repetition of availability zone values, however for effective and easy creation of subnet creation, I repeated them */
/* There is no reason to complicate variable definitions as below, but this is to give an idea of how to handle different variables in their respective order */

variable "serverconfig" {
    description = "Zookeeper EC2 instance configuration"
    type = map(object({
        zk_region           = string
        zk_avail_zone       = list(string)
        zk_ec2_inst_type    = string
        zk_ec2_key_name     = string
        zk_subnets          = map(string)
  }))

    default = {
        test = {
            zk_region           = "us-west-2"
            zk_avail_zone       = ["us-west-2a","us-west-2b","us-west-2c"]
            zk_ec2_inst_type    = "t2.micro"
            zk_ec2_key_name     = "avmk-newkeys"
            zk_subnets          = { 
                "us-west-2a" = "10.0.1.0/24"
                "us-west-2b" = "10.0.2.0/24"
                "us-west-2c" = "10.0.3.0/24"
            }
        }
    }
}

variable "zk_ingressports" {
    type = list(number)
    default = [2181,2888,3888]
}
variable "zk_egressports" {
    type = list(number)
    default = [2181,2888,3888]
}

