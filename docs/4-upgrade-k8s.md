# Update AKS cluster and node pools

In addition to creating clusters, Cluster API allows you to upgrade workload clusters. After creating an AKS cluster, you can update the cluster and node pools to a newer version of Kubernetes.

In this walkthrough, you will upgrade the previously created AKS cluster and one of its node pools.

## Prerequisites

- An existing AKS Cluster that has available upgrades (Refer [this guide](./2-managed-aks-cluster.md) to create one)

## Lab Steps

1. Choose the Kubernetes version you want to upgrade to based on the available upgrades for your cluster.

    ```bash

    # check the current version of the cluster
    echo $KUBERNETES_VERSION

    # check the available upgrades for the cluster
    az aks get-upgrades --resource-group $AZURE_RESOURCE_GROUP --name $CLUSTER_NAME --output table

    ```

    Example output from `az aks get-upgrades` command:
    ![Example output from get-upgrade command](/images/aks-get-upgrades-example.jpg)

2. Set the version variable to the version you want to upgrade to one of the versions from the Upgrades column.

    ```bash

    # TODO: get new k8s version tp upgrade to
    export KUBERNETES_VERSION=1.26.0

    ```

3. First, upgrade the Kubernetes cluster. Generate a patch file with the new version and then apply it to the Cluster API management cluster.

    ```bash

    # generate a patch file with the new version
    clusterctl generate yaml --from ./templates/aks-upgrade.yaml > generated/aks-upgrade-patch.yaml

    # patch the target cluster
    kubectl patch azuremanagedcontrolplane $CLUSTER_NAME --patch-file generated/aks-upgrade-patch.yaml --type=merge

    ```

4. Validate that that the cluster is upgrading. The READY column will show False until AKS has finished upgrading the cluster.

    ```bash

    # check the status of the cluster
    clusterctl describe cluster $CLUSTER_NAME

    ```

    Example output from `clusterctl describe cluster` command:
    ![Example output from describe command](/images/capz-cluster-upgrade-example.jpg)

5. When the Ready column shows True for the ClusterInfrastrcture and ControlPlane rows, you can verify the version of the cluster.

    ```bash

    az aks show --resource-group $AZURE_RESOURCE_GROUP --name $CLUSTER_NAME --output table

    ```

6. Now that the cluster has been upgraded, the individual node pools can be upgraded as well. The field to update is on the MachinePool CRD. Generate a patch file with the new version and apply it to the management cluster.

    ```bash

    # generate a patch file with the new version
    clusterctl generate yaml --from ./templates/aks-nodepool-upgrade.yaml > generated/aks-nodepool-upgrade-patch.yaml

    # view the current machine pools on the target cluster
    kubectl get machinepool -l "cluster.x-k8s.io/cluster-name=${CLUSTER_NAME}"

    # set a name variable for the target node pool that will be upgraded
    export UPGRADE_POOL_NAME="${CLUSTER_NAME}-pool0"

    # patch the target node pool
    kubectl patch machinepool $UPGRADE_POOL_NAME --patch-file generated/aks-nodepool-upgrade-patch.yaml --type=merge

    ```

7. Validate that that the nodepool is upgrading. The READY column will show False until AKS has finished upgrading the target node pool.

    ```bash

    # check the status of the cluster
    clusterctl describe cluster $CLUSTER_NAME

    ```

    Example output from `clusterctl describe cluster` command:
    ![Example output from describe command](/images/capz-nodepool-upgrade-example.jpg)

## Challenge

The AKS cluster and one of the node pools have been upgraded to a newer version of Kubernetes. Now, try upgrading the rest of the node pools in the cluster to the same version.

## Next

[TODO](./5-custom-cluster-configuration.md)
