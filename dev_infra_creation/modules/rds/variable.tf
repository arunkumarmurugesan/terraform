variable "tags" {}
variable "generictag" {}
variable "projectname" {}
variable "env" {}
variable "rds_master_username" {}
variable "rds_master_password" {}
variable "rds_database_name" {}
variable "rds_engine_version" {}
variable "rds_port" {}
variable "rds_instance_class" {}
variable "azs"  {
    type = "map"
}
variable "rds_security_group_id" {}
variable "bastion_security_group_id" {}
variable "private_subnet_ids" {}
variable "region" {}
variable "rds_creation" {
  description = "Whether to create the IAM user"
  type        = bool
}
