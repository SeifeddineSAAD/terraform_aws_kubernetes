variable vpc_name {
    type = string 
    default = "main-vpc"
}

variable "vpc_cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
    type = string
    default = "10.0.0.0/24"
}

variable "subnet_availability_zone" {
    type    = string
    default = "us-east-1a"
}

variable "subnet_name" {
    type    = string
    default = "main-subnet"
  
}