########################### navvis-demo General and Credentials Config ##################################
variable "aws_access_key_id" {
  description = "AWS access key"
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
}

variable "availability_zone" {
  description = "availability zone used for the demo, based on region"
  default = {
    eu-central-1 = "eu-central-1a"
    eu-central-1 = "eu-central-1b"
  }
}


variable "project_name" {
  default = "navvis-demo"
}

########################### navvis-demo VPC Config ##################################

variable "vpc_name" {
  description = "VPC for building demos"
}

variable "vpc_region" {
  description = "AWS region"
}

variable "vpc_cidr_block" {
  description = "Uber IP addressing for demo Network"
}

variable "vpc_subnet_1a_cidr" {
  description = "CIDR for 1a az"
}

variable "vpc_subnet_1b_cidr" {
  description = "CIDR for 1b az"
}

variable "vpc_subnet_1c_cidr" {
  description = "CIDR for 1c az"
}

########################### navvis-demo ec2 Config ##################################

# this is a keyName for key pairs
variable "aws_key_name" {
  description = "Key Pair Name used to provision to the box"
}

variable "inst_ami" {
  description = "Amazon Machine Image for the Instance"
}

variable "inst_type" {
  description = "type of instances to provision"
}

variable "public_ssh_key" {
  description = "Public SSH key value"
}

variable "instance_username" {
  description = "Username for ec2 instance"
  default = "ubuntu"
}

variable "path_to_private_key" {
  description = "Relative/Absolute Path for the private key"
}


