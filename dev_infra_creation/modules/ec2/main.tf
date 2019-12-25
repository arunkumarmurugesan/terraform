resource "aws_eip" "bastion_eip" {
  vpc = true
  tags = "${merge(
    var.tags,
    map(
        "Name", "${var.projectname}-${var.env}-bastion-manager"
    )
  )}"
}

resource "aws_instance" "bastion" {
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_id[0]}"
  key_name                    = "${aws_key_pair.bastion.key_name}"
  vpc_security_group_ids      = "${var.sg_id}"
  associate_public_ip_address = true
  iam_instance_profile        = "${var.iam_role}"
  root_block_device {
    volume_type = "gp2"
    volume_size = "50" 
}
  tags = "${merge(
    var.tags,
    map(
        "Name", "${var.projectname}-${var.env}-bastion-manager"
    )
  )}"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion_eip.id}"
}

resource "aws_key_pair" "bastion" {
  depends_on = [aws_eip.bastion_eip] 
  key_name   = "bastion-key"
  public_key = var.public_key
}