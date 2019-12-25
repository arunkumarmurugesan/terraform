output "subnet_id" {
value = "${aws_subnet.public-subnet.*.id}"
}

output "vpcid" {
value = "${aws_vpc.environment.id}"
}

output "private_subnet_ids" {
value = "${aws_subnet.private-subnet.*.id}"
}

output "prod_route_table_public" {
value = "${aws_route_table.public.id}"
}

output "prod_route_table_private" {
value = "${aws_route_table.private.*.id}"
}

output "prod_nat_gatway_ids" {
value = "${aws_nat_gateway.environment.*.id}"
}


