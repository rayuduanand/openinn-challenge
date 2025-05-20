# RKE2 Airgap Deployment with Ansible

This project provides a straightforward Ansible-based approach for deploying an RKE2 Kubernetes cluster in a completely airgap environment with Harbor registry, complete with essential components for a production-ready setup.

## Components

- **RKE2**: Lightweight Kubernetes distribution in HA configuration
- **Harbor**: Private container registry for airgap environments
- **MetalLB**: Load balancer for bare metal Kubernetes
- **Nginx Ingress**: Ingress controller for external access
- **Longhorn**: Distributed block storage for persistent volumes
- **Velero**: Backup and disaster recovery
- **Monitoring Stack**: Prometheus, Grafana, and Loki for observability

## Directory Structure

```
rke2-ansible/
├── inventory/
│   └── hosts.ini                # Inventory file with node definitions
├── group_vars/
│   └── all.yml                  # Global variables for all hosts
├── playbooks/
│   └── site.yml                 # Main playbook for deployment
├── roles/
│   ├── common/                  # Common setup for all nodes
│   ├── harbor/                  # Harbor registry deployment
│   ├── rke2/                    # RKE2 cluster deployment
│   ├── metallb/                 # MetalLB load balancer
│   ├── ingress/                 # Nginx ingress controller
│   ├── longhorn/                # Longhorn storage
│   ├── velero/                  # Velero backup solution
│   └── monitoring/              # Prometheus, Grafana, and Loki
└── files/                       # Airgap installation files
    ├── charts/                  # Helm charts for airgap installation
    ├── docker/                  # Docker installation packages
    ├── harbor/                  # Harbor installation files
    ├── images/                  # Container images in tar format
    └── rke2/                    # RKE2 installation files
```
This will:
1. Set up common prerequisites on all nodes
2. Deploy Harbor registry
3. Install RKE2 servers in HA configuration
4. Join RKE2 agent nodes
5. Deploy Kubernetes add-ons (MetalLB, Ingress, Longhorn, Velero, Monitoring)

## Prerequisites

1. Ansible control node with:
   - Ansible 2.12+
   - Python 3.8+
   - `kubernetes.core` collection installed

## Airgap Preparation

Before deploying in an airgap environment, you need to prepare all the necessary files on a machine with internet access. This repository includes a preparation script that downloads all required components.

### 1. Prepare Airgap Files

Run the preparation script on a machine with internet access:

```bash
# Create the files directory structure
mkdir -p files/{charts,docker,harbor,images,rke2}

# Download RKE2 files
cd files/rke2
RKE2_VERSION="v1.26.10+rke2r1"
curl -LO "https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-server-${RKE2_VERSION}.linux-amd64.tar.gz"
curl -LO "https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-agent-${RKE2_VERSION}.linux-amd64.tar.gz"
curl -LO "https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-images.linux-amd64.tar.gz"
curl -LO "https://raw.githubusercontent.com/rancher/rke2/master/install.sh"
chmod +x install.sh

# Download Harbor
cd ../harbor
HARBOR_VERSION="v2.7.1"
curl -LO "https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/harbor-offline-installer-${HARBOR_VERSION}.tgz"

# Download Docker
cd ../docker
curl -LO "https://download.docker.com/linux/static/stable/x86_64/docker-24.0.5.tgz"
tar -xzf docker-24.0.5.tgz
mv docker docker-ce
tar -czf docker-ce.tar.gz docker-ce
rm -rf docker-ce docker-24.0.5.tgz
curl -LO "https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64"
chmod +x docker-compose

# Download Helm charts
cd ../charts
helm repo add metallb https://metallb.github.io/metallb
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add longhorn https://charts.longhorn.io
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

helm pull metallb/metallb --version 0.13.10 --destination .
helm pull ingress-nginx/ingress-nginx --version 4.7.1 --destination .
helm pull longhorn/longhorn --version 1.5.1 --destination .
helm pull vmware-tanzu/velero --version 5.0.2 --destination .
helm pull prometheus-community/kube-prometheus-stack --version 45.27.2 --destination .
helm pull grafana/loki-stack --version 2.9.11 --destination .

# Download container images for MinIO
cd ../images
docker pull minio/minio:latest
docker save minio/minio:latest -o minio.tar
```

Transfer all these files to your airgap environment using physical media or a secure file transfer method.

### 2. Configure Inventory

Edit the `inventory/hosts.ini` file to match your environment:

```ini
[rke2_servers]
rke2-server-1 ansible_host=192.168.*.*
rke2-server-2 ansible_host=192.168.*.*
rke2-server-3 ansible_host=192.168.*.*

[rke2_agents]
rke2-agent-1 ansible_host=192.168.*.*
rke2-agent-2 ansible_host=192.168.*.*

[harbor]
harbor ansible_host=192.168.*.*

[k8s_cluster:children]
rke2_servers
rke2_agents

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_become=true
ansible_python_interpreter=/usr/bin/python3
```

### 3. Configure Variables

Review and adjust variables in `group_vars/all.yml` to match your requirements:

```yaml
# RKE2 Configuration
rke2_version: "v1.26.10+rke2r1"
rke2_token: "rke2-cluster-token"
rke2_cni: "canal"
rke2_cluster_cidr: ""
rke2_service_cidr: ""
rke2_cluster_dns: ""

# Harbor Registry Configuration
harbor_version: "v2.7.1"
harbor_admin_password: "Harbor12345"
harbor_hostname: "harbor.local"
harbor_database_password: "root123"

# MetalLB Configuration
metallb_version: "0.13.10"
metallb_address_pool: ""

# Ingress Configuration
ingress_nginx_version: "4.7.1"

# Longhorn Configuration
longhorn_version: "1.5.1"
longhorn_replica_count: 3
longhorn_data_path: "/var/lib/longhorn"

# Velero Configuration
velero_version: "5.0.2"
velero_backup_schedule: "0 1 * * *"  # Daily at 1 AM
velero_backup_retention: "240h"      # 10 days

# Monitoring Configuration
prometheus_stack_version: "45.27.2"
loki_stack_version: "2.9.11"
grafana_admin_password: "admin123"
prometheus_retention: "7d"
loki_retention: "168h"  # 7 days we can chnage this as needed
```

### 4. Run the Deployment

Execute the main playbook:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/site.yml
```

## Accessing the Cluster

After deployment, the kubeconfig file will be available at:

```
files/kubeconfig
```

Use this to access your cluster:

```bash
export KUBECONFIG=$(pwd)/files/kubeconfig
kubectl get nodes
```

## Monitoring and Logging

Access the monitoring dashboards:

- **Grafana**: http://grafana.your-domain.com (or via NodePort)
  - Username: admin
  - Password: as defined in group_vars/all.yml (default: admin)

- **Prometheus**: http://prometheus.your-domain.com (or via NodePort)

- **Loki Logs**: Available in Grafana via the Loki data source

## Backup and Restore with Velero

Velero is configured to take daily backups of critical namespaces. To manually create a backup:

```bash
kubectl -n velero create -f - <<EOF
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: manual-backup
  namespace: velero
spec:
  includedNamespaces:
  - default
  - kube-system
  - ingress-nginx
  - longhorn-system
  - monitoring
  ttl: 720h
EOF
```

To restore from a backup:

```bash
kubectl -n velero create -f - <<EOF
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: restore-from-backup
  namespace: velero
spec:
  backupName: manual-backup
EOF
```
