variable vpc_name {
    type = string 
}

variable "vpc_cidr_block" {
    type = string
}

variable "public_subnets" {
    type = list(object({
        cidr_block           = string
        availability_zone    = string
        name                 = string
    }))
}