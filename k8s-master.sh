#! /bin/bash

# Initialize the master node with kubeadm and install the Calico operator
# The Calico Operator will automatically install the required Calico CNI network components on all of the nodes

# Run kubeadm
# --apiserver-cert-extra-sans is needed to ensure the public IP address of the master
# instance is added to the Server Alternate Name list on the api-server certificate
sudo kubeadm init --apiserver-cert-extra-sans $1 --pod-network-cidr=192.168.0.0/16

# Create kube-config for the cluster
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# # Install Calico
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f - <<EOF
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 192.168.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
EOF

kubeadm token create --print-join-command > join-node.sh

# !! Manual step in the process !!
# At the end of the provisioning process there will be a kubeconfig file in your home directory
# Copy this file to ~/.kube/config and change the private IP address to the pulbic IP address of your cloud provider
