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
