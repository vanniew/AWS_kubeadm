# Provisions masternode, two workernodes and associated security groups
# Uses provisioners to prepare the nodes for kubernetes,
# initialize the master node and join the worker nodes to the cluster

resource "aws_instance" "master-1" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.master-nodes.id]
  source_dest_check           = false

  tags = {
    Name = "master-1"
  }

  provisioner "file" {
    source = "k8s-node-base.sh"
    destination = "/tmp/k8s-node-base.sh"
  }

  provisioner "file" {
    source = "k8s-master.sh"
    destination = "/tmp/k8s-master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s-node-base.sh",
      "chmod +x /tmp/k8s-master.sh",
      "source /tmp/k8s-node-base.sh",
      "source /tmp/k8s-master.sh ${self.public_ip}"
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
  vpc_security_group_ids      = [aws_security_group.worker-nodes.id]
  source_dest_check           = false
  tags = {
    Name = "worker-1"
  }

  # Wait until the join-node script is downloaded from the master node before
  # Provisioning the worker nodes.
  depends_on = [null_resource.get_join_script]

  provisioner "file" {
    source = "k8s-node-base.sh"
    destination = "/tmp/k8s-node-base.sh"
  }

  provisioner "file" {
    source = "join-node.sh"
    destination = "/tmp/join-node.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s-node-base.sh",
      "chmod +x /tmp/join-node.sh",
      "source /tmp/k8s-node-base.sh",
      "sudo /tmp/join-node.sh"
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
  vpc_security_group_ids      = [aws_security_group.worker-nodes.id]
  source_dest_check           = false

  tags = {
    Name = "worker-2"
  }

  # Wait until the join-node script is downloaded from the master node before
  # Provisioning the worker nodes.
  depends_on = [null_resource.get_join_script]

  provisioner "file" {
    source = "k8s-node-base.sh"
    destination = "/tmp/k8s-node-base.sh"
  }

  provisioner "file" {
    source = "join-node.sh"
    destination = "/tmp/join-node.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s-node-base.sh",
      "chmod +x /tmp/join-node.sh",
      "source /tmp/k8s-node-base.sh",
      "sudo /tmp/join-node.sh"
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

# The null_resource will wait until all software has been properly installed on all the nodes.
# As a final step this resource will join the worker nodes to the cluster
resource "null_resource" "get_join_script" {

   provisioner "local-exec" {
     command = "scp -i ${local_file.private_key.filename} -o StrictHostKeyChecking=no ec2-user@${aws_instance.master-1.public_ip}:join-node.sh ."
   }

 }

 # Get the kubeconfig from the remote system
 resource "null_resource" "get_kubeconfig" {

  provisioner "local-exec" {
  command = "scp -i ${local_file.private_key.filename} -o StrictHostKeyChecking=no ec2-user@${aws_instance.master-1.public_ip}:./.kube/config kubeconfig"
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
