resource "aws_vpc_peering_connection" "opstoprod" {
  peer_vpc_id   = "${var.owner_vpc}"
  vpc_id        = "${var.peer_vpc}"
  auto_accept   = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.generictag}vpc-${var.env}vpc-peer"))}"
}

resource "aws_route" "ops_pub_route" {
  route_table_id         = "${var.ops_route_table_public}"
  destination_cidr_block = "${var.prod_vpc_range["cidr_block"]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.opstoprod.id}"
}

resource "aws_route" "ops_pvt_route" {
  count                  = "${length(split(",", lookup(var.azs, var.region)))}"
  route_table_id         = "${var.ops_route_table_private[count.index]}"
  destination_cidr_block = "${var.prod_vpc_range["cidr_block"]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.opstoprod.id}"
}


resource "aws_route" "prod_pub_route" {
  route_table_id         = "${var.prod_route_table_public}"
  destination_cidr_block = "${var.ops_vpc_range["cidr_block"]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.opstoprod.id}"

}

resource "aws_route" "prod_pvt_route" {
  count                  = "${length(split(",", lookup(var.azs, var.region)))}"
  route_table_id         = "${var.prod_route_table_private[count.index]}"
  destination_cidr_block = "${var.ops_vpc_range["cidr_block"]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.opstoprod.id}"
}
