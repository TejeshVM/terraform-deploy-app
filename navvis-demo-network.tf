# Create a VPC to launch our instances into
resource "aws_vpc" "vpc_name" {
  cidr_block = "${var.vpc_cidr_block}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}"
  }
}

# Create a way out to the internet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_name.id}"
  tags = {
        Name = "InternetGateway"
    }
}

# Public route as way out to the internet
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_name.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}


# Create the private route table
resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.vpc_name.id}"

    tags = {
        Name = "Private route table"
    }
}

# Create private route
resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat.id}"
}



# Create a subnet in the AZ eu-central-1a
resource "aws_subnet" "subnet_eu_central_1a" {
  vpc_id                  = "${aws_vpc.vpc_name.id}"
  cidr_block              = "${var.vpc_subnet_1a_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1a"
  tags = {
  	Name =  "Subnet az 1a"
  }
}

# Create a subnet in the AZ eu-central-1b
resource "aws_subnet" "subnet_eu_central_1b" {
  vpc_id                  = "${aws_vpc.vpc_name.id}"
  cidr_block              = "${var.vpc_subnet_1b_cidr}"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = {
  	Name =  "Subnet az 1b"
  }
}

# Create a subnet in the AZ eu-central-1c
resource "aws_subnet" "subnet_eu_central_1c" {
  vpc_id                  = "${aws_vpc.vpc_name.id}"
  cidr_block              = "${var.vpc_subnet_1c_cidr}"
  availability_zone = "eu-central-1c"
  map_public_ip_on_launch = true
  tags = {
  	Name =  "Subnet az 1c"
  }
}

# Create an EIP for the natgateway
resource "aws_eip" "nat" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}


# Create a nat gateway and it will depend on the internet gateway creation
resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.subnet_eu_central_1a.id}"
    depends_on = ["aws_internet_gateway.gw"]
}

# Associate subnet subnet_eu_central_1a to public route table
resource "aws_route_table_association" "subnet_eu_central_1a_association" {
    subnet_id = "${aws_subnet.subnet_eu_central_1a.id}"
    route_table_id = "${aws_vpc.vpc_name.main_route_table_id}"
}

# Associate subnet subnet_eu_central_1b to private route table
resource "aws_route_table_association" "subnet_eu_central_1b_association" {
    subnet_id = "${aws_subnet.subnet_eu_central_1b.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

# Associate subnet subnet_eu_central_1c to private route table
resource "aws_route_table_association" "subnet_eu_central_1c_association" {
    subnet_id = "${aws_subnet.subnet_eu_central_1c.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

