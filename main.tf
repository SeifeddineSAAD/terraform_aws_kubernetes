resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.project_name}-vpc-${local.env}"
  }
}

resource "aws_subnet" "public_subnets" {
  for_each = { for idx, subnet in var.public_subnets : idx => subnet }

  cidr_block = each.value.cidr_block
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.availability_zone


  tags = {
    Name = "${each.value.name}-${local.env}"
  }

  depends_on = [ aws_vpc.main ]
}

resource "aws_subnet" "private_subnets" {
  for_each = { for idx, subnet in var.private_subnets : idx => subnet }

  cidr_block = each.value.cidr_block
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${each.value.name}-${local.env}"
  }

  depends_on = [ aws_vpc.main ]

}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw-${local.env}"
  }

  depends_on = [ aws_vpc.main ]
}

resource "aws_eip" "nat_eip" {
  for_each = { for idx, subnet in var.public_subnets : idx => subnet }
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-${each.key}-${local.env}"
  }

  depends_on = [ aws_vpc.main, aws_subnet.public_subnets ]
}

resource "aws_nat_gateway" "main" {
  for_each = { for idx, subnet in var.public_subnets : idx => subnet }
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.public_subnets[each.key].id

  tags = {
    Name = "${var.project_name}-nat-gw-${each.key}-${local.env}"
  }

  depends_on = [aws_eip.nat_eip]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public-rt-${local.env}"
  }

  depends_on = [ aws_internet_gateway.main ]
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

  depends_on = [aws_internet_gateway.main, aws_route_table.public_rt]
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-rt-${local.env}"
  }

  depends_on = [ aws_nat_gateway.main]
}

resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main[0].id  // Use the desired NAT gateway key

  depends_on = [aws_nat_gateway.main, aws_route_table.private_rt]
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "main-public" {
  name        = "${var.project_name}-sg-public"
  description = "Main security group"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-sg-public-${local.env}"
  }
}

resource "aws_security_group" "main-private" {
  name        = "${var.project_name}-sg-private"
  description = "Main security group"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-sg-private-${local.env}"
  }
}

resource "aws_security_group_rule" "rules_public_sg" {
  for_each = local.public_sg_security_rules
  security_group_id        = aws_security_group.main-public.id

  type                     = each.value.rule_type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.dst_sg != "" ? aws_security_group.main-private.id : null
  cidr_blocks               = each.value.dst_cidr != "" ? [each.value.dst_cidr] : null
  description              = "Allow all inbound traffic from within the same security group"
}

resource "aws_security_group_rule" "rules_private_sg" {
  for_each = local.private_sg_security_rules
  security_group_id        = aws_security_group.main-private.id

  type                     = each.value.rule_type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.dst_sg != "" ? aws_security_group.main-public.id : null
  cidr_blocks               = each.value.dst_cidr != "" ? [each.value.dst_cidr] : null
  description              = "Allow all inbound traffic from within the same security group"
}

