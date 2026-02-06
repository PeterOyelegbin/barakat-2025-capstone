# Create a VPC
resource "aws_vpc" "vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name    = "${var.project_name}-vpc"
        Project = "Bedrock"
    }
}

# Create Public Subnets
resource "aws_subnet" "public" {
    count                   = length(var.public_subnet_cidrs)
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.public_subnet_cidrs[count.index]
    availability_zone       = var.availability_zones[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name    = "${var.project_name}-public-subnet-${count.index + 1}"
        Project = "Bedrock"
    }
}

# Create Private Subnets
resource "aws_subnet" "private" {
    count             = length(var.private_subnet_cidrs)
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = var.private_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name    = "${var.project_name}-private-subnet-${count.index + 1}"
        Project = "Bedrock"
    }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name    = "${var.project_name}-igw"
        Project = "Bedrock"
    }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
    domain = "vpc"
    tags = {
        Name    = "${var.project_name}-nat-eip"
        Project = "Bedrock"
    }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public[0].id

    tags = {
        Name    = "${var.project_name}-nat"
        Project = "Bedrock"
    }

    depends_on = [aws_internet_gateway.igw]
}

# Create a Route Table for Public Subnets
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name    = "${var.project_name}-public-rt"
        Project = "Bedrock"
    }
}

# Create a Route Table for Private Subnets
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
        Name    = "${var.project_name}-private-rt"
        Project = "Bedrock"
    }
}

# Associate the Route Table with the Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
