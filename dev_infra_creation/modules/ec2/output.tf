output "bastion_server" {
value = "${aws_instance.bastion.id}"
}

output "bastion_server_eip" {
value = "${aws_eip.bastion_eip.public_ip}"
}
