#!/bin/bash

# this runs as part of pre-build

echo "on-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create start" >> "$HOME/status"

export REPO_BASE=$PWD
export EXP_MACHINE_POOL=true
export EXP_AKS=true
export AZURE_CLUSTER_IDENTITY_SECRET_NAME='cluster-identity-secret'
export CLUSTER_IDENTITY_NAME='cluster-identity'
export AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE='default'

mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.oh-my-zsh/completions"

{
    echo "export REPO_BASE=$REPO_BASE"

    # Settings needed for AzureClusterIdentity used by the AzureCluster
    echo "export AZURE_CLUSTER_IDENTITY_SECRET_NAME=$AZURE_CLUSTER_IDENTITY_SECRET_NAME"
    echo "export CLUSTER_IDENTITY_NAME=$CLUSTER_IDENTITY_NAME"
    echo "export AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE=$AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE"

    # set vm type for Azure provider
    echo "export AZURE_CONTROL_PLANE_MACHINE_TYPE='Standard_A2_v2'"
    echo "export AZURE_NODE_MACHINE_TYPE='Standard_A2_v2'"

    # set aks feature flag
    echo "export EXP_MACHINE_POOL=$EXP_MACHINE_POOL"
    echo "export EXP_AKS=$EXP_AKS"

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
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.5.1/clusterctl-linux-amd64 -o clusterctl
chmod +x ./clusterctl
sudo mv ./clusterctl /usr/local/bin/clusterctl

echo "generating completions"
gh completion -s zsh > ~/.oh-my-zsh/completions/_gh
kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"
k3d completion zsh > "$HOME/.oh-my-zsh/completions/_k3d"
clusterctl completion zsh > "$HOME/.oh-my-zsh/completions/_clusterctl"

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

# run this to regenerate cluster congfiguration
# echo "generating cluster configuration"
# clusterctl generate cluster capi-quickstart --flavor development \
#   --kubernetes-version v1.25.0 \
#   --control-plane-machine-count=1 \
#   --worker-machine-count=1 \
#   > capi-quickstart.yaml

# echo "applying cluster manifest"
# kubectl apply -f "$REPO_BASE"/capi-quickstart.yaml

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
