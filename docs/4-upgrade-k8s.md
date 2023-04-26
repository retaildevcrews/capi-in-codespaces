# Update AKS cluster and node pools

In addition to creating clusters, Cluster API allows you to upgrade workload clusters. After creating an AKS cluster, you can update the control plane and node pools to a newer version of Kubernetes.

In this walkthrough, you will upgrade the previously created AKS cluster and one of its node pools.

## Prerequisites

- An existing AKS Cluster that has available upgrades (Refer [this guide](./2-managed-aks-cluster.md) to create one)

## Lab Steps

1. Choose the kubernetes version you want to upgrade to based on the available upgrades for your cluster.

    ```bash

    # check the current version of the cluster
    echo $KUBERNETES_VERSION

    # check the available upgrades for the cluster
    az aks get-upgrades --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --output table

    ```

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
