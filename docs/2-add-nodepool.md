# Add a NodePool to an AKS Cluster

Diffrent application workloads need different compute resources. With the benefit of Kubernetes, you can have multiple node pools, each containing different types of instances/machines.

In this walktrhough, we will create new node pools in your existing AKS cluster using Cluster API.

## Prerequisites

- An existing AKS Cluster (Refer [this guide](./1-managed-aks-cluster.md) to create one)

## Add a Node Pool to an AKS Cluster

- Validate and set required environement variables:

  > - Refer [clusterctl docs](https://cluster-api.sigs.k8s.io/clusterctl/commands/generate-yaml.html) to learn more about `clusterctl generate yaml` command
  > - Refer [limitations](https://learn.microsoft.com/en-us/azure/aks/use-multiple-node-pools#limitations) for creating AKS nodepools

   ```bash

   # print list of variables used in the local template
   clusterctl generate yaml --from ./templates/aks-nodepool.yaml --list-variables

   # set and validate required variables
   # Variable $CLUSTER_NAME should be same as your existing AKS cluster name
   # The name of a node pool may only contain lowercase alphanumeric characters and must begin with a lowercase letter. For Linux node pools the length must be between 1 and 12 characters, for Windows node pools the length must be between 1 and 6 characters
   export POOL_NAME=nodepoolaks
   echo $CLUSTER_NAME

   ```

- Generate the nodepool configuration. The generated file represents 1 AKS node pool. The file is separate from the previous yaml file that created the AKS cluster, showing that new Cluster API config files can be generated to manage node pools separately from the cluster.

  ```bash

  clusterctl generate yaml --from ./templates/aks-nodepool.yaml > capz-${POOL_NAME}.yaml

  ```

- Open the file to review the contents.

  ```bash

  code capz-${POOL_NAME}.yaml

  ```

- Apply the nodepool configuration to workload cluster:

  ```bash

  kubectl apply -f capz-${POOL_NAME}.yaml

  ```

- Validate new nodepool in AKS cluster resources:

  ```bash

  clusterctl describe cluster $CLUSTER_NAME

  ```

- Open the Cluster API Visualizer app to view the latest state of your AKS cluster with a newly added NodePool.
  In the "PORTS" tab, click the "Open in Browser" button for the visualizer app.
  ![Open Cluster API Visualizer](/images/open-capi-visualizer.png)

## Challenge

The node pool created in this section was a System node pool with 1 node. Now create a new User node pool with 2 nodes. Review the yaml file for the previous node pool for hints on changes to make for the new node pool.

```bash

code capz-${POOL_NAME}.yaml

```

After creating a new User node pool, use `kubectl` to find all the AKS node pools that Cluster API is managing.
