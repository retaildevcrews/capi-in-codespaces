# Add a NodePool to an AKS Cluster

Diffrent application workloads need different compute resources. With the benefit of Kubernetes, you can have multiple node pools, each containing different types of instances/machines.

In this walktrhough, we will create new node pools in your existing AKS cluster using Cluster API.

## Prerequisites

- An existing AKS Cluster (Refer [this guide](./2-managed-aks-cluster.md) to create one)

## Lab Steps

1. Validate and set required environement variables:

    > - Refer [clusterctl docs](https://cluster-api.sigs.k8s.io/clusterctl/commands/generate-yaml.html) to learn more about `clusterctl generate yaml` command
    > - Refer [limitations](https://learn.microsoft.com/en-us/azure/aks/use-multiple-node-pools#limitations) for creating AKS nodepools

      ```bash

      # print list of variables used in the local template, some of the variables are not required as they have set defaults in the template
      clusterctl generate yaml --from ./templates/aks-nodepool.yaml --list-variables

      # set and validate required variables
      # Variable $CLUSTER_NAME should be same as your existing AKS cluster name
      echo $CLUSTER_NAME

      # The name of a node pool may only contain lowercase alphanumeric characters and must begin with a lowercase letter. For Linux node pools the length must be between 1 and 12 characters, for Windows node pools the length must be between 1 and 6 characters
      export POOL_NAME=nodepoolaks
      echo $POOL_NAME

      ```

      ```bash

      # There are a lot of SKU's for VM's and some are limited by region, for more information see https://learn.microsoft.com/en-us/azure/virtual-machines/sizes this tool is also avaliable for finding an appropriate SKU
      export POOL_MACHINE_SKU=Standard_A2_v2 # If not set defaults to Standard_A2_v2
      echo $POOL_MACHINE_SKU
      # Pool mode is used to designate node pool as a System or User node pool, acceptable values are User or System
      export POOL_MODE=User # If not set defaults to User
      echo $POOL_MODE
      # Pool disk size sets the disk size for the OS
      export POOL_DISK_SIZE=40 # If not set defaults to 30
      echo $POOL_DISK_SIZE
      # Pool min and max size sets parameters for autoscaler to use for minumum and maximum counts of nodes in the node pool
      export POOL_MIN_SIZE=1 # If not set defaults to 1
      export POOL_MAX_SIZE=2 # If not set defaults to 1
      echo $POOL_MIN_SIZE
      echo $POOL_MAX_SIZE

      ```

2. Generate the nodepool configuration. The generated file represents 1 AKS node pool. The file is separate from the previous yaml file that created the AKS cluster, showing that new Cluster API config files can be generated to manage node pools separately from the cluster.

    ```bash

    clusterctl generate yaml --from ./templates/aks-nodepool.yaml > "generated/capz-${POOL_NAME}.yaml"

    ```

3. Open the file to review the contents.

    ```bash

    code "generated/capz-${POOL_NAME}.yaml"

    ```

4. Apply the nodepool configuration to workload cluster:

    ```bash

    kubectl apply -f "generated/capz-${POOL_NAME}.yaml"

    ```

5. Validate new nodepool in AKS cluster resources:

    ```bash

    clusterctl describe cluster $CLUSTER_NAME

    ```

6. Open the Cluster API Visualizer app to view the latest state of your AKS cluster with a newly added NodePool.
  In the "PORTS" tab, click the "Open in Browser" button for the visualizer app.
  ![Open Cluster API Visualizer](/images/open-capi-visualizer.png)

## Challenge

The node pool created in this section was a System node pool with 1 node. Now create a new User node pool with 2 nodes. Review the yaml file for the previous node pool for hints on changes to make for the new node pool.

```bash

code "generated/capz-${POOL_NAME}.yaml"

```

After creating a new User node pool, use `kubectl` to find all the AKS node pools that Cluster API is managing.

## Next

Continue with [Upgrade AKS version](./4-upgrade-k8s.md) lab. This lab will walk you through upgrading your AKS cluster and node pools.
