variable "env" {}
variable "projectname" {}
variable "office_ips" { type = "list" }
variable "tags" {}
variable "region" {}
variable "es_version" {}
variable "es_instance_type" {}
variable "es_ebs_volume_size" {}
variable "es_instance_count" {}
variable "es_zone_awareness" {}
variable "es_creation" {
  description = "Whether to create the IAM user"
  type        = bool
}


