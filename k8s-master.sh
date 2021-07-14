#! /bin/bash

# Initialize the master node with kubeadm and install the Calico operator
# The Calico Operator will automatically install the required Calico CNI network components on all of the nodes

# Run kubeadm
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

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

# Manually run the command stored in the worker-join-token file on every worker node that joins the cluster.
# The token expires in 24 hours. After that time expired, create a new token on the master node using the same command.
