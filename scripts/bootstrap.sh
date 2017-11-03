#!/usr/bin/env bash
 
set -o nounset
set -o pipefail
set -o errexit
 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y \
    apt-transport-https \
    socat \
    ebtables \
    cloud-utils \
    cloud-init \
    cloud-initramfs-growroot \
    docker.io=1.12.6-0ubuntu1~16.04.1 \
    kubelet=1.7.5-00 \
    kubeadm=1.7.5-00 \
    kubernetes-cni=0.5.1-00 \
    sysstat \
    iotop \
    rsync \
    ngrep \
    tcpdump \
    atop \
    python-pip \
    curl \
    jq

# We don't want to upgrade them.
apt-mark hold kubeadm kubectl kubelet kubernetes-cni

apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes 
#install helm
curl https://storage.googleapis.com/kubernetes-helm/helm-${HELM_RELEASE_TAG}-linux-amd64.tar.gz | tar xz --strip 1 -C /usr/bin/

#Helm Charts
mkdir /opt/helm 
cd /opt/helm
helm init -c
helm repo add banzaicloud-stable http://$HELM_REPO_USER:$HELM_REPO_PASS@kubernetes-charts.banzaicloud.com
helm repo update
helm repo list
helm fetch banzaicloud-stable/pipeline-cp
tar -xvzf pipeline-cp*
helm fetch banzaicloud-stable/spark
tar -xvzf spark*
helm fetch banzaicloud-stable/zeppelin-spark
tar -xvzf zeppelin-spark*
rm -rf /home/ubuntu/.helm

pip install --upgrade pip

systemctl enable docker
systemctl start docker

sudo pip install awscli
sudo pip install json2yaml

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
  "gcr.io/google_containers/kube-state-metrics:v1.1.0-rc.0"
  "bitnami/mariadb:10.1.28-r2"
  "grafana/grafana:latest"
  "traefik:1.4.1"
  "prom/prometheus:v1.8.0"
  "jimmidyson/configmap-reload:v0.1"
  "quay.io/calico/node:v1.3.0"
  "quay.io/calico/cni:v1.9.1"
)

for i in "${images[@]}" ; do docker pull "${i}" ; done
