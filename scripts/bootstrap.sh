#!/usr/bin/env bash
 
set -o nounset
set -o pipefail
set -o errexit

export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb https://download.docker.com/linux/ubuntu xenial stable" > /etc/apt/sources.list.d/docker-ce.list

apt-get update -y
apt-get install -y \
    apt-transport-https \
    socat \
    ebtables \
    cloud-utils \
    cloud-init \
    cloud-initramfs-growroot \
    docker-ce=17.12.0~ce-0~ubuntu \
    kubectl="${KUBERNETES_VERSION}-00" \
    kubelet="${KUBERNETES_VERSION}-00" \
    kubeadm="${KUBERNETES_VERSION}-00" \
    kubernetes-cni=0.6.0-00 \
    sysstat \
    iotop \
    rsync \
    ngrep \
    tcpdump \
    atop \
    python-pip \
    curl \
    jq \
    unzip

# We don't want to upgrade them.
apt-mark hold kubeadm kubectl kubelet kubernetes-cni docker-ce

systemctl enable docker
systemctl start docker

apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes

#install helm
curl https://storage.googleapis.com/kubernetes-helm/helm-${HELM_RELEASE_TAG}-linux-amd64.tar.gz | tar xz --strip 1 -C /usr/bin/

pip install --upgrade pip

systemctl enable docker
systemctl start docker

sudo pip install json2yaml

helm completion bash > /etc/bash_completion.d/helm
kubectl completion bash > /etc/bash_completion.d/kubectl

images=(
  "gcr.io/google_containers/kube-proxy-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-apiserver-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-scheduler-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-controller-manager-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/etcd-amd64:${ETCD_RELEASE_TAG}"
  "gcr.io/google_containers/pause-amd64:3.0"
  "gcr.io/google_containers/k8s-dns-sidecar-amd64:${K8S_DNS_RELEASE_TAG}"
  "gcr.io/google_containers/k8s-dns-kube-dns-amd64:${K8S_DNS_RELEASE_TAG}"
  "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:${K8S_DNS_RELEASE_TAG}"
  "gcr.io/kubernetes-helm/tiller:${HELM_RELEASE_TAG}"
)

for i in "${images[@]}" ; do docker pull "${i}" ; done
