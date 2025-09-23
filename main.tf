resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "main" {
  cidr_block = var.subnet_cidr_block
  vpc_id            = aws_vpc.main.id
  availability_zone = var.subnet_availability_zone           # Change as needed

  tags = {
    Name = var.subnet_name
  }
}