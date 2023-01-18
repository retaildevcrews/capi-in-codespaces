# Add Node Pools to an AKS Cluster

Diffrent application workloads need different compute resources. With the benefit of Kubernetes, you can have multiple node pools, each containing different types of instances/machines.

In this walktrhough, we will create new node pools in your existing AKS cluster using Cluster API.

## Prerequisites

- An existing AKS Cluster (Refer [this guide](./1-managed-aks-cluster.md) to create one)

## Add a Node Pool to an AKS Cluster

- Set Environement variables

   ```bash

   # print list of variables used in the local template
   clusterctl generate yaml --from ./templates/aks-nodepool.yaml --list-variables

   # set and validate required variables
   # Variable $CLUSTER_NAME should be same as your existing AKS cluster name
   export POOL_NAME = aks-nodepool
   echo $CLUSTER_NAME

   ```

- Generate yaml

  ```bash

  clusterctl generate yaml --from ./templates/aks-nodepool.yaml > aks-nodepool.yaml

  ```

- Apply the configuration to workload cluster

  ```bash

  kubectl apply -f aks-nodepool.yaml

  ```

- Validate new nodepool in AKS cluster resources

  ```bash

  clusterctl describe cluster $CLUSTER_NAME
  
  ```
