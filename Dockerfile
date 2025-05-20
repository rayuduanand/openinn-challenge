FROM ubuntu:22.04

LABEL maintainer="RKE2 Airgap Preparation"
LABEL description="Container for preparing air-gapped RKE2 Kubernetes deployments"

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV WORKSPACE=/workspace

WORKDIR ${WORKSPACE}

# Install system packages
RUN apt-get update && apt-get install -y \
    curl wget gnupg lsb-release ca-certificates \
    python3 python3-pip python3-venv \
    git unzip jq vim net-tools \
    iproute2 iputils-ping dnsutils netcat \
    openssh-client sshpass \
    apt-transport-https \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Docker Compose (static binary)
RUN curl -L "https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod +x get_helm.sh && ./get_helm.sh && rm get_helm.sh

# Install Helmfile binary only
RUN curl -fsSL -o /usr/local/bin/helmfile https://github.com/helmfile/helmfile/releases/download/v0.151.0/helmfile_linux_amd64 && \
    chmod +x /usr/local/bin/helmfile

# Install Ansible and Kubernetes collection
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install ansible==5.8.0 ansible-core==2.12.6 && \
    ansible-galaxy collection install kubernetes.core

# Prepare workspace structure
RUN mkdir -p ${WORKSPACE}/files/{charts,docker,harbor,images,rke2,helmfile}

# Copy local rke2-ansible files (optional)
COPY rke2-ansible/ ${WORKSPACE}/rke2-ansible/

# Add preparation script
RUN echo '#!/bin/bash\n\
set -euo pipefail\n\
\n\
echo "Creating directory structure..."\n\
mkdir -p files/{charts,docker,harbor,images,rke2,helmfile}\n\
\n\
echo "Downloading RKE2..." && cd files/rke2\n\
RKE2_VERSION="v1.26.10+rke2r1"\n\
curl -LO "https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-server-${RKE2_VERSION}.linux-amd64.tar.gz"\n\
curl -LO "https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-agent-${RKE2_VERSION}.linux-amd64.tar.gz"\n\
curl -LO "https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-images.linux-amd64.tar.gz"\n\
curl -LO "https://raw.githubusercontent.com/rancher/rke2/master/install.sh" && chmod +x install.sh\n\
\n\
echo "Downloading Harbor offline installer..." && cd ../harbor\n\
HARBOR_VERSION="v2.7.1"\n\
curl -LO "https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/harbor-offline-installer-${HARBOR_VERSION}.tgz"\n\
\n\
echo "Downloading MinIO image..." && cd ../images\n\
docker pull minio/minio:latest\n\
docker save minio/minio:latest -o minio.tar\n\
\n\
echo "Downloading Helmfile binary..." && cd ../helmfile\n\
HELMFILE_VERSION="v0.151.0"\n\
curl -LO "https://github.com/helmfile/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64"\n\
chmod +x helmfile_linux_amd64\n\
\n\
echo "Airgap preparation complete. Check files/ directory."\n\
echo "Transfer files/ to your air-gapped environment."\n' > ${WORKSPACE}/prepare-airgap.sh

# Make script executable
RUN chmod +x ${WORKSPACE}/prepare-airgap.sh

CMD ["/bin/bash"]