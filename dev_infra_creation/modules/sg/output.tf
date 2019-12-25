output "wazuh_manager_security_group_id" {
  value = ["${aws_security_group.wazuh_master_sg.id}"]
}
output "wazuh_client_security_group_id" {
  value = ["${aws_security_group.wazuh_client_sg.id}"]
}
output "bastion_security_group_id" {
  value = ["${aws_security_group.bastion.id}"]
}
output "rds_security_group_id" {
  value = ["${aws_security_group.rds.id}"]
}