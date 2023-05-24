data "aws_availability_zones" "available" {
  state = "available"
}


# vpc creation
resource "aws_vpc" "custom" {
  cidr_block = "var.vpc_cidr"
  enable_dns_hostnames="true"
  tags = {
    Name = var.envname
  }
}

# igw creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom.id
  tags = {
    Name = var.envname
  }
}

# public subnet creation

resource "aws_subnet" "public_cidr" {
  vpc_id     = aws_vpc.custom.id
  count=length(var.public_cidr)
  cidr_block = element(var.public_cidr.id,count.index)
  availability_zone = element(data.aws_availability_zones.available.names,count.index)
   tags = {
    Name = "${var.envname}-public-subnet-${count.index+1}"
  }

}

# private subnet creation
resource "aws_subnet" "private_cidr" {
  vpc_id     = aws_vpc.custom.id
  count=length(var.private_cidr)
  cidr_block = element(var.private_cidr.id,count.index)
  availability_zone = element(data.aws_availability_zones.available.names,count.index)
   tags = {
    Name = "${var.envname}-private-subnet-${count.index+1}"
  }

}


# data subnet creation

resource "aws_subnet" "data_cidr" {
  vpc_id     = aws_vpc.custom.id
  count=length(var.data_cidr)
  cidr_block = element(var.data_cidr.id,count.index)
  availability_zone = element(data.aws_availability_zones.available.names,count.index)
   tags = {
    Name = "${var.envname}-data-subnet-${count.index+1}"
  }

}


# eip creation

resource "aws_eip" "eip" {
  vpc      = true
  tags = {
    Name = var.envname
  }
}

#nat creation

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_cidr[0].id

  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = var.envname
  }
}


# public route creation
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.custom.id

  route {
    cidr_block ="0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.envname}-public"
  }

}


# private route creation
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.custom.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.envname}-private"
  }

}

#public subnets associtaion

resource "aws_route_table_association" "public" {
  count          = length(var.public_cidr)
  subnet_id      = element(aws_subnet.public_cidr.*.id, count.index)
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_cidr)
  subnet_id      = element(aws_subnet.private_cidr.*.id, count.index)
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "data" {
  count          = length(var.data_cidr)
  subnet_id      = element(aws_subnet.data_cidr.*.id, count.index)
  route_table_id = aws_route_table.private_route.id
}


