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

# Start k3s server with native snapshotter for Docker Desktop compatibility
exec k3s server \
    --write-kubeconfig-mode=644 \
    --disable=traefik \
    --disable=servicelb \
    --snapshotter=native \
    --node-name=${NODE_NAME:-master} \
    --cluster-init=${CLUSTER_INIT:-true} \
    ${K3S_TOKEN:+--token=$K3S_TOKEN}