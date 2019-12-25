resource "null_resource" "generate-sshkey" {
    provisioner "local-exec" {
        command = "yes y | ssh-keygen -b 4096 -t rsa -C 'terraform-kubernetes' -N '' -f ${var.ssh_gen.private_key}"
    }
    create_key_pair = false 
}