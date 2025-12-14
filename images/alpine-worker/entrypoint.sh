#!/bin/bash
set -e

# Load kernel modules
modprobe overlay 2>/dev/null || true
modprobe br_netfilter 2>/dev/null || true

# Apply sysctl
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.bridge.bridge-nf-call-iptables=1

# Start containerd
containerd &
sleep 3

# Wait for master
echo "Waiting for master..."
while ! curl -k https://${MASTER_IP:-master}:6443/ping &>/dev/null; do
    sleep 2
done

# Join cluster with native snapshotter for Docker Desktop compatibility
exec k3s agent \
    --server=https://${MASTER_IP:-master}:6443 \
    --token=${K3S_TOKEN} \
    --snapshotter=native \
    --node-name=${NODE_NAME:-worker}