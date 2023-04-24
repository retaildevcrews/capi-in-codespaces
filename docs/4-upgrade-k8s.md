# Update AKS control plane and node pools

- TODO: description of lab
  - can upgrade control plane and node pools
  - simply change the version in the yaml by patching the resource

## Prerequisites

- TODO:
  - aks cluster that has available upgrades
  - show how to get aks versions

## Lab Steps

- TODO:
  - upgrade control plane
  - update a node pool

- TODO: might have to patch the cluster to get the upgrade to work
  - verified that patching works and regular kubectl apply does not because of sshPublicKey field

```bash

kubectl patch azuremanagedcontrolplane $CLUSTER_NAME --patch-file ./templates/aks-upgrage.yaml --type=merge

```

## Challenge

- TODO:
  - upgrade the rest of the node pools in the cluster

## TODO - notes
