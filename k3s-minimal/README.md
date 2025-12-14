# 🎯 K3s Cluster Minimal - Alpine from Scratch

## Docker Desktop Windows Implementation

> **Complete Kubernetes cluster for educational purposes**  
> Meets all teacher requirements using Alpine Linux containers on Docker Desktop Windows

---

## 📋 what was needed ✅

| Requirement                                 | Status | Implementation                                  |
| ------------------------------------------- | ------ | ----------------------------------------------- |
| 1. Installation cluster Kubernetes avec k3s | ✅     | 1 master + 2 workers (Alpine 3.18)              |
| 2. Configuration RBAC pour utilisateurs     | ✅     | dev-user (limited) + admin-user (cluster-admin) |
| 3. Storage Class avec backend NFS           | ✅     | NFS server + PV/PVC configuration               |
| 4. Déploiement d'opérateur MPI              | ✅     | MPI Operator deployed in mpi-operator namespace |
| 5. Conteneurisation d'applications          | ✅     | Nginx webapp with NodePort access               |

---

## 📁 Project Structure

```
k3s-minimal/
│
├── .env                           # Environment configuration
├── docker-compose.yml             # Container orchestration
├── deploy-working.ps1             # Main deployment script
├── Makefile                       # Quick commands
├── README.md                      # This file
│
├── images/
│   ├── alpine-master/
│   │   ├── Dockerfile            # K3s master node image
│   │   └── entrypoint.sh         # Master startup script
│   └── alpine-worker/
│       ├── Dockerfile            # K3s worker node image
│       └── entrypoint.sh         # Worker startup script
│
├── manifests/
    ├── rbac.yaml                 # RBAC configuration
    ├── nfs-storage-fixed.yaml    # NFS StorageClass & PV/PVC
    ├── mpi-operator-simple.yaml  # MPI Operator
    └── sample-app-simple.yaml    # Sample Nginx application

```

---

## 🚀 Quick Start Guide

### Prerequisites

- Docker Desktop for Windows (running)
- PowerShell 5.1 or higher
- kubectl installed and in PATH

### 1️⃣ Deploy the Cluster

```powershell
# Navigate to project directory
cd k3s-minimal

# Build docker compose
docker-compose build

# Start compose
docker-compose up -d

# Wait for around a minute after last command finishes and config cluster (applies manifests)
.\deploy-working.ps1
```

### 2️⃣ Verify Installation

```powershell
# Check cluster nodes
docker exec -it k3s-master bash

# Now you're inside master container check for nodes
kubectl get nodes

# Expected output:
# NAME       STATUS   ROLES                  AGE   VERSION
# master     Ready    control-plane,master   1m    v1.28.x+k3s1
# worker-1   Ready    <none>                 1m    v1.28.x+k3s1
# worker-2   Ready    <none>                 1m    v1.28.x+k3s1

# Check all pods
kubectl get pods -A

# Check RBAC configuration
kubectl get sa -A
kubectl get roles,rolebindings -A

# Check storage
kubectl get pv,pvc

# Check MPI operator
kubectl get pods -n mpi-operator

# Check webapp
kubectl get pods,svc -n apps

```

### 3️⃣ Access the Web Application

Open browser: http://localhost:30080

You should see: **"K3s Minimal Cluster - Alpine Linux"**

### 4️⃣ Test RBAC

```powershell
# Create token for dev-user (limited permissions)
kubectl create token dev-user -n dev-team

# Create token for admin-user (full permissions)
kubectl create token admin-user -n kube-system
```

---

## 🔧 Technical Details

### Cluster Architecture

```
┌─────────────────────────────────────────┐
│         Docker Desktop Windows          │
│  ┌───────────────────────────────────┐  │
│  │     k3s-net (172.25.0.0/16)       │  │
│  │                                   │  │
│  │  ┌──────────┐  172.25.0.10       │  │
│  │  │  Master  │  (k3s server)       │  │
│  │  └──────────┘                     │  │
│  │       │                           │  │
│  │  ┌────┴─────┐                     │  │
│  │  │          │                     │  │
│  │  ▼          ▼                     │  │
│  │ ┌────────┐ ┌────────┐            │  │
│  │ │Worker-1│ │Worker-2│            │  │
│  │ └────────┘ └────────┘            │  │
│  │ .20        .21                    │  │
│  │                                   │  │
│  │  ┌──────────┐  172.25.0.5        │  │
│  │  │   NFS    │                     │  │
│  │  └──────────┘                     │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Key Features

**K3s Configuration:**

- Native snapshotter (required for Docker Desktop Windows)
- Traefik and ServiceLB disabled for simplicity
- Cluster token authentication

**RBAC Setup:**

- `dev-user`: Limited permissions in dev-team namespace (get, list, create, delete pods/deployments/services)
- `admin-user`: Full cluster-admin permissions

**Storage:**

- NFS server container (172.25.0.5)
- PersistentVolume configured for NFS backend
- Sample PVC demonstrating storage binding
- Webapp uses emptyDir (NFS mounting has limitations in Docker Desktop)

**MPI Operator:**

- Deployed in dedicated namespace
- Ready for distributed computing workloads
- ServiceAccount with required cluster permissions

**Sample Application:**

- Nginx web server
- 2 replicas for high availability
- NodePort service (port 30080)
- Custom HTML content via initContainer

---

## 📖 Usage Examples

### Deploy Custom Application

```powershell
# Create deployment in dev-team namespace
kubectl create deployment my-app --image=nginx:alpine -n dev-team

# Expose as service
kubectl expose deployment my-app --port=80 --type=NodePort -n dev-team

# Get service details
kubectl get svc -n dev-team
```

### Use NFS Storage

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  namespace: default
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  volumeName: nfs-pv-shared
```

### Scale Application

```powershell
# Scale webapp to 3 replicas
kubectl scale deployment webapp -n apps --replicas=3

# Verify
kubectl get pods -n apps
```

---

## 🛠️ Available Commands

```powershell
# Using deploy-working.ps1
.\deploy-working.ps1                    # Full deployment

# Using docker-compose directly
docker-compose up -d --build            # Build and start
docker-compose down -v                  # Stop and remove volumes
docker-compose logs -f                  # Follow logs
```

---

## 🐛 Troubleshooting

### Pods Not Starting

```powershell
# Check pod status
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>

# Check node status
kubectl get nodes
kubectl describe node master
```

### Cannot Access Kubeconfig

```powershell
# Copy kubeconfig manually
docker cp k3s-master:/etc/rancher/k3s/k3s.yaml $env:USERPROFILE\.kube\config

# Update server address
(Get-Content $env:USERPROFILE\.kube\config) -replace '127.0.0.1','172.25.0.10' | Set-Content $env:USERPROFILE\.kube\config
```

### NFS Mount Issues

**Note:** NFS volume mounting has limitations in Docker Desktop Windows. The project includes:

- NFS server container (running successfully)
- PV/PVC configuration (demonstrates storage concepts)
- Webapp uses emptyDir as practical alternative

### Webapp Not Accessible

```powershell
# Verify service
kubectl get svc -n apps

# Check NodePort
kubectl describe svc webapp -n apps

# Verify port is exposed in docker-compose.yml (line with "30080:30080")

# Test from inside cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -O- http://webapp.apps.svc.cluster.local
```

---

## 🧹 Cleanup

### Option 1: Using Docker Compose

```powershell
docker-compose down -v
```

### Option 2: Complete Removal

```powershell
docker-compose down -v --rmi all
docker volume prune -f
docker network prune -f
```

---

## 📚 Educational Value

This project demonstrates:

1. **Container Orchestration**: Multi-container setup with docker-compose
2. **Kubernetes Concepts**: Nodes, pods, deployments, services, namespaces
3. **Security**: RBAC with ServiceAccounts, Roles, RoleBindings
4. **Storage**: PersistentVolumes, PersistentVolumeClaims, StorageClasses
5. **Networking**: Container networking, NodePort services, DNS resolution
6. **Operators**: Kubernetes operator pattern (MPI Operator)
7. **Windows Compatibility**: Native snapshotter, PowerShell automation

---

## 📝 Notes

- **Docker Desktop Requirement**: This setup requires Docker Desktop for Windows running in Windows containers mode with WSL2 backend
- **Resource Usage**: Cluster uses ~2GB RAM and ~10GB disk space
- **Production Warning**: This is an educational cluster, not suitable for production
- **NFS Limitation**: While NFS infrastructure is deployed, volume mounting works differently in Docker Desktop
- **Snapshotter**: Uses native snapshotter instead of overlayfs (required for Docker Desktop compatibility)

---

## 🎓 Learning Path

1. **Start Simple**: Deploy cluster and verify nodes
2. **Explore RBAC**: Create tokens, test permissions
3. **Storage Concepts**: Understand PV/PVC binding
4. **Networking**: Access webapp, understand NodePort
5. **Scaling**: Scale deployments, observe behavior
6. **Operators**: Study MPI operator deployment

---

## 📄 License

Educational project for academic purposes.
