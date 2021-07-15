#! /bin/bash

# This shell script installs all the prequisite components to start a kubernetes node
# The components installed include docker, kubelet, kubeadm and kubectl
# Initialization of the master-node with kube-adm is in a different script.
# This script only contains operations that are the same on worker and master nodes

# Ensure that IPTables can see bridged traffic. br_netfilter module should be loaded net.bridge.bridge-nf-call-iptables shoudl be set to 1
# Check that BR_NETFIlTER module is properly installed sudo sysctl --system
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Install the docker runtime. Use "docker info" command to verify that the installation was successfull
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Configure the docker daemon, in particular to use systemd for the management of the container's security_groups
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart docker and enable on boot
nosudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# Install kubelet and kubeadm
# Set SELinux in permissive mode (effectively disabling it)
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

# Install kubectl using native package management - https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl

# Install tc
sudo yum install tc -y
