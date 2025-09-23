resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnets" {
  for_each = { for idx, subnet in var.public_subnets : idx => subnet }

  cidr_block = each.value.cidr_block
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.value.name
  }
}