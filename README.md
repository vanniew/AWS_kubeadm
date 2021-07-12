# The scripts in this directory will install a fully functional K8s Cluster based on kubeadm in AWS
The different files in this directory perform different steps in the installation process.
The main files in this terraform directory are:
- main.tf             - Provisions the networking in AWS to deploy the cluster (VPC/Subnets/Gateways/etc...)
- master-nodes-sg.tf  - Provisions the security groups to enable communication between the master nodes and the worker nodes and the master nodes and the internet
- worker-nodes-sg.tf  - Provisions the security groups to enable communication between the worker nodes.
- Instances           - Deploy the instances that make up the cluster

## Step 1: Provision the required network infrastructure and AMI in AWS
terraform init
terraform apply
