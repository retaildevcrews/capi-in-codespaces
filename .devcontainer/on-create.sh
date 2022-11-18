#!/bin/bash

# this runs as part of pre-build

echo "on-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create start" >> "$HOME/status"

export REPO_BASE=$PWD

mkdir -p "$HOME/.ssh"

{
    echo "export REPO_BASE=$REPO_BASE"
    echo "compinit"
} >> "$HOME/.zshrc"

# can remove once incorporated in base image
echo "Updating k3d to 5.4.6"
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v5.4.6 bash

# create local registry
docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

# update the base docker images
docker pull mcr.microsoft.com/dotnet/aspnet:6.0-alpine
docker pull mcr.microsoft.com/dotnet/sdk:6.0

###
### kind
###
# install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

echo "creating kind cluster"
kind create cluster --config .devcontainer/kind-extramounts.yaml


###
### K3D
###
# echo "creating k3d cluster"
# k3d cluster create \
#     --registry-use k3d-registry.localhost:5500 \
#     --k3s-arg '--no-deploy=traefik@server:0' \
#     --config '.devcontainer/k3d.yaml'

echo "install clusterctl"
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.2.5/clusterctl-linux-amd64 -o clusterctl
chmod +x ./clusterctl
sudo mv ./clusterctl /usr/local/bin/clusterctl

# enable the experimental Cluster topology feature.
export CLUSTER_TOPOLOGY=true

# initialize the management cluster
clusterctl init --infrastructure docker

# The list of service CIDR, default ["10.128.0.0/12"]
export SERVICE_CIDR=["10.96.0.0/12"]

# The list of pod CIDR, default ["192.168.0.0/16"]
export POD_CIDR=["192.168.0.0/16"]

# The service domain, default "cluster.local"
export SERVICE_DOMAIN="k8s.test"

export ENABLE_POD_SECURITY_STANDARD="false"

echo "generating cluster configuration"
clusterctl generate cluster capi-quickstart --flavor development \
  --kubernetes-version v1.25.0 \
  --control-plane-machine-count=3 \
  --worker-machine-count=3 \
  > capi-quickstart.yaml

# only run apt upgrade on pre-build
if [ "$CODESPACE_NAME" = "null" ]
then
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get autoremove -y
    sudo apt-get clean -y
fi

echo "on-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create complete" >> "$HOME/status"
