# ECS Instance Security group
resource "aws_security_group" "vpc_private_sg" {
  name = "${var.project_name}-ssh-sg"
  description = "common security group for all"
  vpc_id = "${aws_vpc.vpc_name.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_subnet_1a_cidr}", "${var.vpc_subnet_1b_cidr}", "${var.vpc_subnet_1c_cidr}"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16"]
  }

  egress {
    # allow all traffic to all SNs
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "{var.project_name}-ssh-sg"
  }
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "navvis_demo_elb"
  description = "Security group for ELB"
  vpc_id      = "${aws_vpc.vpc_name.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "vpc_private_sg_id" {
  value = "${aws_security_group.vpc_private_sg.id}"
}

