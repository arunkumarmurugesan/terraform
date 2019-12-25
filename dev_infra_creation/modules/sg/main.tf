
resource "aws_security_group" "wazuh_master_sg" {
    name = "${var.projectname}-${var.env}-wazuh-master-sg"
    description = "The wazuh master security group"
    vpc_id = "${var.ops_vpc}"

    ingress {
        from_port = 5601
        to_port = 5601
        protocol = "tcp"
        description = "Allow the wazuh manager port to example Office IPs from wazuh manager server to access the kibana console"
        cidr_blocks = "${var.office_ips}" 
    }
    
    ingress {
    from_port = 1922
    to_port = 1922
    protocol = "tcp"
    description = "Allow the SSH Port to example Office IPs from wazuh manager to ssh to the server"
    cidr_blocks = "${var.office_ips}" 
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = "${merge(
    var.tags,
    map(
        "Name", "${var.projectname}-${var.env}-wazuh-master-sg"
    )
  )}"
}

resource "aws_security_group" "wazuh_client_sg" {
    #depends_on = [aws_security_group.wazuh_master_sg]
    name = "${var.projectname}-${var.env}-wazuh-client-sg"
    description = "The wazuh client security group"
    vpc_id = "${var.prod_vpc}"

    ingress {
        from_port = 1514
        to_port = 1514
        protocol = "udp"
        description = "Allow the UDP connection for wazuh manager from client server to connect to the wazuh master"
        security_groups = [ "${aws_security_group.wazuh_master_sg.id}" ]
        #cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
    from_port = 1515
    to_port = 1515
    protocol = "udp"
    description = "Allow the UDP connection for wazuh manager from client server to connect to the wazuh master"
    security_groups = [ "${aws_security_group.wazuh_master_sg.id}" ]
     #cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = "${merge(
    var.tags,
    map(
        "Name", "${var.projectname}-${var.env}-wazuh-client-sg"
    )
  )}"
}

resource "aws_security_group" "bastion" {
    name = "${var.projectname}-${var.env}-bastion-sg"
    description = "The bastion security group"
    vpc_id = "${var.ops_vpc}"

    ingress {
        from_port = 1922
        to_port = 1922
        protocol = "tcp"
        description = "Allow the SSH Port to example Office IPs from bastion server to ssh to the server"
        cidr_blocks = "${var.office_ips}" 
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = "${merge(
    var.tags,
    map(
        "Name", "${var.projectname}-${var.env}-bastion-sg"
    )
  )}"
}

resource "aws_security_group" "rds" {
    name = "${var.projectname}-${var.env}-rds-sg"
    description = "The aurora postgres database security group"
    vpc_id = "${var.prod_vpc}"
    
    ingress {
    from_port = 6567
    to_port = 6567
    protocol = "tcp"
    description = "Allowed the inbound connection to VPC CIDR"
    cidr_blocks = [ "${var.prod_vpc_range}" ]
    }

    ingress {
    from_port = 6567
    to_port = 6567
    protocol = "tcp"
    description = "Allowed the inbound connection to bastion server"
    security_groups  = ["${aws_security_group.bastion.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = "${merge(
    var.tags,
    map(
        "Name", "${var.projectname}-${var.env}-rds-sg"
    )
  )}"
}

