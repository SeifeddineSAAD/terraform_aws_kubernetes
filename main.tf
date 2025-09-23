resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)

  cidr_block = var.public_subnets[count.index].cidr_block
  vpc_id            = aws_vpc.main.id
  availability_zone = var.public_subnets[count.index].availability_zone

  tags = {
    Name = var.public_subnets[count.index].name
  }
}