resource "aws_route53_zone" "private" {
  name          = "${var.cluster_name}"
  vpc {
    vpc_id = "${var.prod_vpc}"
  }
  force_destroy = true
    tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.env}-${var.cluster_name}-private-zone"))}"
}