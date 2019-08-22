# SSH key pair for accessing ec2 machine
resource "aws_key_pair" "sshKeyPair" {
  key_name   = "${var.aws_key_name}"
  public_key = "${var.public_ssh_key}"
}
