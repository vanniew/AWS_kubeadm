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

kubeadm token create --print-join-command > worker-join-token

# This output is generated at the end of the kubeadm command
# Adding K8s nodes is done with running this command as root on any node you want to add
# kubeadm join 10.2.101.76:6443 --token 1b24tu.n7vtvttr7ts3syxf --discovery-token-ca-cert-hash sha256:40d308baca9d8de8edd206e04affdc49a59cf30ba2b1a04dde2ecd37778636db
