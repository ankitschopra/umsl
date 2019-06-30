data "aws_availability_zones" "available" {
  state = "${var.azs_state}"
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags                 = "${map("Name", "test-base-vpc")}"
}

#PUBLIC SUBNETS
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "public" {
  count             = "${var.public_subnet_count}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${cidrsubnet(var.cidr_block, var.newbits, count.index)}"
  vpc_id            = "${aws_vpc.main.id}"
  tags              = "${map("Name", "public-subnet-${element(split(",", "${data.aws_availability_zones.available.names[count.index]}"), count.index)}")}"
}


resource "aws_route_table_association" "public" {
  count          = "${var.public_subnet_count}"
  route_table_id = "${aws_vpc.main.main_route_table_id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_route" "public" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

#PRIVATE SUBNETS
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [ "aws_internet_gateway.main" ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on    = [ "aws_internet_gateway.main", "aws_eip.nat_eip" ]
}

resource "aws_subnet" "private" {
  count             = "${var.private_subnet_count}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${cidrsubnet(var.cidr_block, var.newbits, 30 + count.index)}"
  vpc_id            = "${aws_vpc.main.id}"
  tags              = "${map("Name", "private-subnet-${element(split(",", "${data.aws_availability_zones.available.names[count.index % var.azs_count ]}"), count.index)}")}"
}

resource "aws_route_table" "private" {
  count  = "${var.azs_count}"
  vpc_id = "${aws_vpc.main.id}"
  tags   = "${map("Name", "private-${element(split(",", "${data.aws_availability_zones.available.names[count.index]}"), count.index)}")}"
}

resource "aws_route" "internet_route_private" {
  count                  = "${var.azs_count}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count          = "${var.private_subnet_count}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}

