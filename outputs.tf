# To make it easier to work with the cluster, this script will output some commonly used variables

output "master-1-public-ip" {
  value = aws_instance.master-1.public_ip
}

output "worker-1-private-ip" {
  value = aws_instance.worker-1.private_ip
}

output "worker-2-private-ip" {
  value = aws_instance.worker-2.private_ip
}
