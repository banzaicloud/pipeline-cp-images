## ControlPlane K8s POC
### List targets
```bash
make list
```

### Dry run
```bash
DRY_RUN=1 \
make build-aws-ubuntu-xenial
```

### Run with user environment
```
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_REGION="eu-west-1"
export AWS_DEFAULT_REGION="eu-west-1"
#export AWS_SPOT_PRICE=""
export AWS_SSH_USERNAME="ubuntu"
export AWS_SOURCE_AMI="ami-da28dfa3"
export AWS_INTANCE_TYPE="c4.large"
export KUBERNETES_RELEASE_TAG="v1.7.3"
export ETCD_RELEASE_TAG="3.0.17"
export K8S_DNS_RELEASE_TAG="1.14.4"
export HELM_RELEASE_TAG="v2.6.2"
export GITHUB_TOKEN=""

make build-aws-ubuntu-xenial
```

### Limitation/Known issue
We cannot use AWS_SPOT_PRICE 
https://github.com/hashicorp/packer/issues/2763

### Supported regions
```
eu-central-1
eu-west-2
us-east-1
us-east-2
us-west-1
us-west-2
```

##Latest Iamge
ami-7c28da05

