# Bastion ec2 Instance to connect with private instances
resource "aws_instance" "bastion" {
  instance_type = "${var.inst_type}"
  ami = "${var.inst_ami}"
  availability_zone = "eu-central-1a"
  subnet_id = "${aws_subnet.subnet_eu_central_1a.id}"
  key_name = "${aws_key_pair.sshKeyPair.key_name}"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.vpc_private_sg.id}"]

  connection {
    host = "${aws_instance.bastion.public_ip}"
    type = "ssh"
    user = "${var.instance_username}"
    private_key = "${file("${var.path_to_private_key}")}"
  }

  provisioner "remote-exec" {
    inline = ["echo 'CONNECTED to BASTION!'"]
  }

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

# private ec2 instances on 1st AZ
resource "aws_instance" "az1_instances" {
  count = "3"
  ami = "${var.inst_ami}"
  availability_zone = "eu-central-1b"
  instance_type = "${var.inst_type}"
  key_name = "${aws_key_pair.sshKeyPair.key_name}"
  subnet_id = "${aws_subnet.subnet_eu_central_1b.id}"
  source_dest_check = false
  associate_public_ip_address = false
  security_groups = ["${aws_security_group.vpc_private_sg.id}"]

  connection {
    bastion_host = "${aws_instance.bastion.public_ip}"
    host         = self.private_ip
    user = "${var.instance_username}"
    private_key = "${file("${var.path_to_private_key}")}"
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p /home/ubuntu/workspace"]
  }

  provisioner "file" {
    source = "demo-app/demo-0.0.1-SNAPSHOT.jar"
    destination = "/home/ubuntu/workspace/demo-0.0.1-SNAPSHOT.jar"
  }

  provisioner "file" {
    source = "demo-app/install_java_demo_app.sh"
    destination = "/home/ubuntu/workspace/install_java_demo_app.sh"
  }
  
  provisioner "file" {
    source = "demo-app/navvis-demo-daemon.service"
    destination = "/home/ubuntu/workspace/navvis-demo-daemon.service"
  }
  

  provisioner "file" {
    source = "demo-app/navvis-demo-script"
    destination = "/home/ubuntu/workspace/navvis-demo-script"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /home/ubuntu/workspace/install_java_demo_app.sh", "sudo /home/ubuntu/workspace/install_java_demo_app.sh"]
  }

  tags = {
    Name = "${var.project_name}-az1-instances-${count.index}"
  }
}

# private ec2 instances on 2nd AZ
resource "aws_instance" "az2_instances" {
  count = "2"
  ami = "${var.inst_ami}"
  availability_zone = "eu-central-1c"
  instance_type = "${var.inst_type}"
  key_name = "${aws_key_pair.sshKeyPair.key_name}"
  subnet_id = "${aws_subnet.subnet_eu_central_1c.id}"
  source_dest_check = false
  associate_public_ip_address = false
  security_groups = ["${aws_security_group.vpc_private_sg.id}"]

  connection {
    bastion_host = "${aws_instance.bastion.public_ip}"
    host         = self.private_ip
    user = "${var.instance_username}"
    private_key = "${file("${var.path_to_private_key}")}"
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p /home/ubuntu/workspace"]
  }

  provisioner "file" {
    source = "demo-app/demo-0.0.1-SNAPSHOT.jar"
    destination = "/home/ubuntu/workspace/demo-0.0.1-SNAPSHOT.jar"
  }

  provisioner "file" {
    source = "demo-app/install_java_demo_app.sh"
    destination = "/home/ubuntu/workspace/install_java_demo_app.sh"
  }
  
  provisioner "file" {
    source = "demo-app/navvis-demo-daemon.service"
    destination = "/home/ubuntu/workspace/navvis-demo-daemon.service"
  }
  

  provisioner "file" {
    source = "demo-app/navvis-demo-script"
    destination = "/home/ubuntu/workspace/navvis-demo-script"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /home/ubuntu/workspace/install_java_demo_app.sh", "sudo /home/ubuntu/workspace/install_java_demo_app.sh"]
  }

  tags = {
    Name = "${var.project_name}-az2-instances-${count.index}"
  }
}


resource "aws_elb" "navvisElb" {
  name = "navvis-demo-elb"

  subnets = [
    "${aws_subnet.subnet_eu_central_1a.id}",
    "${aws_subnet.subnet_eu_central_1b.id}",
    "${aws_subnet.subnet_eu_central_1c.id}",
  ]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = "${aws_instance.az1_instances.*.id}"

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
}


resource "aws_elb_attachment" "elb_attachment" {
  elb      = "${aws_elb.navvisElb.id}"
  instance = "${aws_instance.az2_instances.0.id}"
}

resource "aws_elb_attachment" "elb_attachment-1" {
  elb      = "${aws_elb.navvisElb.id}"
  instance = "${aws_instance.az2_instances.1.id}"
}

output "bastion_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "az1_instance_ips" {
  value = ["${aws_instance.az1_instances.*.private_ip}"]
}

output "az2_instance_ips" {
  value = ["${aws_instance.az2_instances.*.private_ip}"]
}

output "elb_dns_name" {
  value = "${aws_elb.navvisElb.dns_name}"
}
