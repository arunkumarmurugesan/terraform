
output "ops_public_subnet_id" {
value = "${module.ops_vpc.subnet_id}"
}

output "ops_private_subnet_ids" {
value = "${module.ops_vpc.private_subnet_ids}"
}

output "prod_public_subnet_id" {
value = "${module.prod_vpc.subnet_id}"
}

output "prod_private_subnet_ids" {
value = "${module.prod_vpc.private_subnet_ids}"
}

output "ops_vpcid" {
value = "${module.ops_vpc.vpcid}"
}

output "prod_vpcid" {
value = "${module.prod_vpc.vpcid}"
}

output "wazuh_manager_security_group_ids" {
  value = ["${module.sg.wazuh_manager_security_group_id}"]
}
output "wazuh_client_security_group_ids" {
  value = ["${module.sg.wazuh_client_security_group_id}"]
}

output "iot_cert" {
value = "${module.acm.iot_cert}"
}

output "example_cert" {
value = "${module.acm.example_cert}"
}

output "es_arn" {
    value = "${module.elasticsearch.es_arn}"
}
output "es_domain_id" {
    value = "${module.elasticsearch.es_domain_id}"
}
output "es_endpoint" {
    value = "${module.elasticsearch.es_endpoint}"
}
output "es_kibana_endpoint" {
    value = "${module.elasticsearch.es_kibana_endpoint}"
}

output "rds_master_kms_arn" {
    value = "${module.kms.rds_kms_arn}"
}

output "es_master_kms_arn" {
    value = "${module.kms.es_kms_arn}"
}
output "kops_state_store" {
  value = "s3://${module.s3.kops_state_store}"
}

output "privatedns" {
  value = "${module.privatedns.private_zone_id}"
}

output "app01_user_access_keys" {
  value = "${module.iam.app01_user_keys}"
}

output "app01_user_access_key_secret" {
  value = "${module.iam.app01_user_access_key_secret}"
}

output "app02_user_access_key" {
  value = "${module.iam.app02_user_access_key}"
}

output "app02_user_access_key_secret" {
  value = "${module.iam.app02_user_access_key_secret}"
}

output "app03_user_access_key" {
  value = "${module.iam.app03_user_access_key}"
}

output "app03_user_access_key_secret" {
  value = "${module.iam.app03_user_access_key_secret}"
}

output "velero_user_access_key" {
  value = "${module.iam.velero_user_access_key}"
}

output "velero_user_access_key_secret" {
  value = "${module.iam.velero_user_access_key_secret}"
}

output "dr_region" {
  value = "${var.region}"
}

output "rds_password" {
  value = "${var.rds_master_password}"
}

output "rds_writer_endpoint" {
  value = "${module.rds.db_cluster_master_writer_endpoint}"
}

output "rds_reader_endpoint" {
  value = "${module.rds.db_cluster_master_reader_endpoint}"
}

output "app01_kms_arn" {
  value = "${module.kms.app01_kms_arn}"
}

output "availability_zones" {
  #value = "${var.azs}"
  value = "${lookup(var.azs, var.region)}"
}

output "image_id" {
  value = "${var.ami_id}"
}

output "clustername" {
  value = "${var.env}.${var.cluster_name}"
}
output "master_instance" {
  value = "${var.master_instance}"
}
output "node_instance" {
  value = "${var.node_instance}"
}
output "kube_version" {
  value = "${var.kube_version}"
}
output "env" {
  value = "${var.env}"
}

output "prod_nat_gatway_ids" {
  value = "${module.prod_vpc.prod_nat_gatway_ids}"
}

output "prod_vpc_cidr" {
  value = "${var.prod_vpc_cidr_id}"
}

output "ops_vpc_cidr" {
  value = "${var.ops_vpc_cidr_id}"
}

output "rl_node_instance" {
  value = "${var.rl_node_instance}"
}

output "bastion_instance_profile_role" {
  value = "${module.iam.bastion_instance_profile_role}"
}

output "dr_velero_backup_name" {
  value ="${var.dr_velero_backup_name}"
}
output "bastion_role_arn" {
  value = "${module.iam.bastion_role_arn}"
}
output "office_ips" {
  value = "${var.office_ips}"
}
output "dr_bastion_ip" {
  value = "${module.ec2.bastion_server_eip}"
}
output "dr_db_name" {
  value = "${var.dr_db_name}"
}

output "dr_namespaces" {
  value = "${var.dr_namespaces}"
}

output "domain_name" {
  value = "${var.domain_name}"
}