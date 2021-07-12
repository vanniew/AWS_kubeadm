resource "aws_instance" "master-1" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  security_groups             = [aws_security_group.master-nodes.id]

  tags = {
    Name = "master-1"
  }

  provisioner "file" {
    source = "k8s-node-base.sh"
    destination = "/tmp/k8s-node-base.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s-node-base.sh",
      "sudo /tmp/k8s-node-base.sh"
    ]
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = self.public_ip
    private_key = file("${local_file.private_key.filename}")
  }

}

resource "aws_instance" "worker-1" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = false
  subnet_id                   = module.vpc.private_subnets[0]
  security_groups             = [aws_security_group.worker-nodes.id]

  tags = {
    Name = "worker-1"
  }

  provisioner "file" {
    source = "k8s-node-base.sh"
    destination = "/tmp/k8s-node-base.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s-node-base.sh",
      "sudo /tmp/k8s-node-base.sh"
    ]
  }

  # For the worker nodes we will use the master nodes as bastion hosts
  connection {
    type                  = "ssh"
    bastion_host          = "${aws_instance.master-1.public_ip}"
    bastion_private_key   = file("${local_file.private_key.filename}")
    bastion_user          = "ec2-user"
    host                  = self.private_ip
    private_key           = file("${local_file.private_key.filename}")
    user                  = "ec2-user"
  }
}

resource "aws_instance" "worker-2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = false
  subnet_id                   = module.vpc.private_subnets[0]
  security_groups             = [aws_security_group.worker-nodes.id]

  tags = {
    Name = "worker-2"
  }

  provisioner "file" {
    source = "k8s-node-base.sh"
    destination = "/tmp/k8s-node-base.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s-node-base.sh",
      "sudo /tmp/k8s-node-base.sh"
    ]
  }

  # For the worker nodes we will use the master nodes as bastion hosts
  connection {
    type                  = "ssh"
    bastion_host          = "${aws_instance.master-1.public_ip}"
    bastion_private_key   = file("${local_file.private_key.filename}")
    bastion_user          = "ec2-user"
    host                  = self.private_ip
    private_key           = file("${local_file.private_key.filename}")
    user                  = "ec2-user"
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
  filename          = "tf-key.pem"
  sensitive_content = tls_private_key.key.private_key_pem
  file_permission   = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "tf-key"
  public_key = tls_private_key.key.public_key_openssh
}
