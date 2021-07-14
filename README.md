# Purpose of this terraform module
**K8s Cluster**
The goal of this terraform module is to install a fully functional K8s cluster, consisting of one master node and two worker-nodes. Although KOPS is commonly used as a provisioning tool for AWS, we will use kubeadm in this module because it is the most basic provisioning tool and is more generic.  

**Security**
We implement baseline security so that the cluster is only accessible from the internet through the master node. The worker nodes can only access the internet through a NAT gateway. Communication to the worker-nodes is only permitted through the master node.

**CNI**
As a CNI Calico in VXLANCrossSubnet mode is used. This means that between workernodes traffic is sent unencapsulated but between worker and master nodes traffic is encapsulated with VXLAN.


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
