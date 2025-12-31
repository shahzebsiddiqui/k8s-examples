#!/bin/bash

# Script to set up a single-node Kubernetes cluster on Rocky Linux 9 using kubeadm
# Run as root or with sudo
# Tested based on current best practices as of December 2025

set -e  # Exit on any error

echo "Updating system packages..."
#dnf update -y

echo "Disabling swap..."
swapoff -a
# Permanently disable swap in fstab
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "Loading kernel modules..."
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

echo "Setting sysctl parameters for Kubernetes..."
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

dnf install -y dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo dnf install -y conntrack-tools

echo "Installing containerd..."
dnf install -y containerd.io

# Configure containerd to use systemd cgroup driver (required for kubelet)
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

echo "Adding Kubernetes repository (latest stable as of now)..."
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl
EOF

echo "Installing kubeadm, kubelet, and kubectl..."
dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

echo "Pulling Kubernetes images..."
kubeadm config images pull

echo "Initializing single-node Kubernetes cluster..."
# Use Calico CIDR; stain removed for single-node (allows scheduling on control plane)
kubeadm init --pod-network-cidr=192.168.0.0/16

echo "Setting up kubectl for root user..."
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown root:root /root/.kube/config

echo "Installing Calico pod network..."
# Apply Calico manifest
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

echo "Removing control plane taint (for single-node cluster)..."
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "Kubernetes single-node cluster setup complete!"
echo "Verify with: kubectl get nodes -o wide"
echo "And: kubectl get pods -A"
