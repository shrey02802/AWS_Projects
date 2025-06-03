resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "SD-vpc"
  }
}

variable "Availability_zones" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b"]
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  count             = length(var.Availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index)
  availability_zone = element(var.Availability_zones, count.index)
  tags = {
    Name = "SD public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  count             = length(var.Availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(var.Availability_zones, count.index)
  tags = {
    Name = "SD private subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "SD internet_gateway"
  }
}

resource "aws_route_table" "aws_route_table_public_subnet" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "public subnet route table"
  }
}

resource "aws_route" "internet_gateway" {
  route_table_id         = aws_route_table.aws_route_table_public_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "aws_public" {
  route_table_id = aws_route_table.aws_route_table_public_subnet.id
  count          = length(var.Availability_zones)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)

  depends_on = [aws_route_table.aws_route_table_public_subnet,
                aws_subnet.public_subnet]
}

resource "aws_eip" "name" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = element(aws_subnet.public_subnet[*].id, 0)
  allocation_id = aws_eip.name.id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "sd_natgateway"
  }
}

resource "aws_route_table" "aws_route_table_private_subnet" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "private subnet route table"
  }
}
resource "aws_route" "nat_acces" {
  route_table_id         = aws_route_table.aws_route_table_private_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "private_subnet_association" {
  route_table_id = aws_route_table.aws_route_table_private_subnet.id
  count          = length(var.Availability_zones)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
}
