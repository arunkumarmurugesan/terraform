##data "aws_availability_zone" "az" {
#  count = "${length(var.azs)}"
#  name  = "${var.azs[count.index]}"
#}

resource "aws_vpc" "environment" {
    cidr_block           = "${var.ops_vpc_range["cidr_block"]}"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.generictag}-vpc"))}"
}

resource "aws_internet_gateway" "environment" {
    vpc_id = "${aws_vpc.environment.id}"
    tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.generictag}-ig"))}"    
}

resource "aws_subnet" "public-subnet" {
    vpc_id            = "${aws_vpc.environment.id}"
    count             = "${length(split(",", lookup(var.azs, var.region)))}"
    cidr_block        = "${cidrsubnet(var.ops_vpc_range["cidr_block"], var.ops_vpc_range["subnet_bits"], count.index)}"
    availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"
    tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.generictag}-public-subnet-${count.index}"))}"
    map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.environment.id}"
  tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.generictag}-ops-public-routetable"))}"
}

resource "aws_route" "igw_route" {
  #count                  = "${length(split(",", lookup(var.azs, var.region)))}"
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.environment.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", lookup(var.azs, var.region)))}"
  subnet_id      = "${aws_subnet.public-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "private-subnet" {
    vpc_id            = "${aws_vpc.environment.id}"
    count             = "${length(split(",", lookup(var.azs, var.region)))}"
    cidr_block        = "${cidrsubnet(var.ops_vpc_range["cidr_block"], var.ops_vpc_range["subnet_bits"], count.index + length(split(",", lookup(var.azs, var.region))))}"
    availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"
    tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.generictag}-private-subnet-${count.index}"))}"
}

resource "aws_eip" "natgateway-eip" {
  count = "${length(split(",", lookup(var.azs, var.region)))}"
  vpc           = true
  tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.generictag}-eip"))}"
}


resource "aws_nat_gateway" "environment" {
  count             = "${length(split(",", lookup(var.azs, var.region)))}"
  allocation_id     = "${aws_eip.natgateway-eip.*.id[count.index]}"
  subnet_id         = "${aws_subnet.public-subnet.*.id[count.index]}"
  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["subnet_id"]
  }
  tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.env}-natgateway-${count.index}"))}"
}

resource "aws_route_table" "private" {
  count = "${length(split(",", lookup(var.azs, var.region)))}"
  vpc_id = "${aws_vpc.environment.id}"
  tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.generictag}-private-routetable"))}"
}


resource "aws_route" "nat_route" {
  count                  = "${length(split(",", lookup(var.azs, var.region)))}"  
  route_table_id         = "${aws_route_table.private.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.environment.*.id[count.index]}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(split(",", lookup(var.azs, var.region)))}"
  subnet_id      = "${aws_subnet.private-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.*.id[count.index]}"
}


