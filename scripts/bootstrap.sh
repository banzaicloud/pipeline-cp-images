#!/usr/bin/env bash
 
set -o nounset
set -o pipefail
set -o errexit

export DEBIAN_FRONTEND=noninteractive

export KUBERNETES_RELEASE_TAG=v${KUBERNETES_VERSION}

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb https://download.docker.com/linux/ubuntu xenial stable" > /etc/apt/sources.list.d/docker-ce.list

add-apt-repository -y ppa:longsleep/golang-backports

apt-get update -y

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    curl \
    socat \
    ebtables \
    cloud-utils \
    cloud-init \
    cloud-initramfs-growroot \
    docker-ce="5:18.09.0~3-0~ubuntu-xenial" \
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
    jq \
    unzip \
    golang-go

# We don't want to upgrade them.
apt-mark hold kubeadm kubectl kubelet kubernetes-cni docker-ce

systemctl enable docker
systemctl start docker

#install envtpl
GOPATH=/tmp/go go get github.com/subfuzion/envtpl/... && mv /tmp/go/bin/envtpl /usr/local/bin/envtpl

apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes

#install vault
curl -O https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/bin
rm vault_${VAULT_VERSION}_linux_amd64.zip

#install helm
curl https://storage.googleapis.com/kubernetes-helm/helm-${HELM_RELEASE_TAG}-linux-amd64.tar.gz | tar xz --strip 1 -C /usr/bin/

systemctl enable docker
systemctl start docker

pip install json2yaml

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
