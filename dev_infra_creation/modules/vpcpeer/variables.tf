
variable "peer_vpc" {
}
variable "owner_vpc" {
}

variable "ops_vpc_range" {
type =map
}
variable "prod_vpc_range" {
type =map
}

variable "prod_route_table_public" {}
variable "prod_route_table_private" {}

variable "ops_route_table_public" {}
variable "ops_route_table_private" {}
variable "tags" {}
variable "generictag" {}
variable "projectname" {}
variable "env" {}
variable "region" {}
variable "azs"  {
type = map
}
