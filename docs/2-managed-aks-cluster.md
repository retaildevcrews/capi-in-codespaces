# Provision AKS Cluster using CAPZ

Cluster API Provider Azure (CAPZ) supports managing Azure Kubernetes Service (AKS) clusters. CAPZ implements this with three custom resources:

- AzureManagedControlPlane
- AzureManagedCluster
- AzureManagedMachinePool

The combination of `AzureManagedControlPlane`/`AzureManagedCluster` corresponds to provisioning an AKS cluster. `AzureManagedMachinePool` corresponds one-to-one with AKS node pools.

## Prerequisites

In order to create Azure resources, the Azure provider requires a Service Principal with sufficient permissions in the target subscription.

Login with the az CLI.

```bash

az login

```

Set your desired subscription.

```bash

az account set -s "<subscription name or ID>"

# verify the desired account is selected
az account show

```

Create the `generated` directory for storing templated files if you have not done so already.

```bash

mkdir -p generated

```

### Setup Service Principal and credentials

An Azure Service Principal is needed for deploying Azure resources. The below instructions utilize [environment-based authentication](https://docs.microsoft.com/en-us/go/azure/azure-sdk-go-authorization#use-environment-based-authentication).

> NOTE: Some the required environment variables are set as part of the devcontainer setup. For more information about authorization, AAD, or requirements for Azure, visit the [Azure provider prerequisites document](https://capz.sigs.k8s.io/topics/getting-started.html#prerequisites)

The script below will create a Service Principal, create a kubernetes secret with the Service principal credentials, then initialize the Azure provider in the Cluster API management cluster.
You'll need sufficient permissions to create the Service Principal.

```bash

# Preview the commands for setting up the Azure provider
code scripts/azure-provider-setup.sh

# Run the script and save the exported environment variable
source ./scripts/azure-provider-setup.sh

# Validate env variables for Azure provider
env | grep AZURE

```

- AZURE_CLUSTER_IDENTITY_SECRET_NAME
- AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE
- AZURE_TENANT_ID
- AZURE_SUBSCRIPTION_ID
- AZURE_CAPI_SP_NAME
- AZURE_CLIENT_ID
- AZURE_NODE_MACHINE_TYPE (Set as `Standard_A2_v2` for this lab)
- AZURE_CONTROL_PLANE_MACHINE_TYPE (Set as `Standard_A2_v2` for this lab)

## Lab Steps

1. A clusterctl flavor exists to deploy an AKS cluster with CAPZ. This flavor requires the following environment variables to be set before executing clusterctl.

    > NOTE: When choosing a version of Kubernetes, ensure that it is at least N-1 of the latest version of Kubernetes supported by AKS. This will ensure that the cluster has an available version to upgrade to in the later labs.

    ```bash

    # Kubernetes values
    export CLUSTER_NAME=capz-$(echo $GITHUB_USER | tr '[:upper:]' '[:lower:]')-aks
    export WORKER_MACHINE_COUNT=1

    # validate valid kubernetes version for a given location by running
    az aks get-versions -l eastus -o table

    # set the desired kubernetes version to a one that has available upgrades
    export KUBERNETES_VERSION="v1.28.0"

    # Azure values
    export AZURE_LOCATION="eastus"
    export AZURE_RESOURCE_GROUP=$CLUSTER_NAME-rg

    ```

2. Managed cluster also requires AKS feature flags set in order to provision cluster using AKS flavor:

    ```bash

    echo $EXP_MACHINE_POOL
    echo $EXP_AKS

    ```

3. Validate Cluster Identity secret in kind cluster which includes the password of the Service Principal identity created in Azure. This secret will be referenced by the AzureClusterIdentity used by the AzureCluster.

    ```bash

    kubectl get secret $AZURE_CLUSTER_IDENTITY_SECRET_NAME
    # if not set, create a new secret by executing this command:
    # kubectl create secret generic "${AZURE_CLUSTER_IDENTITY_SECRET_NAME}" --from-literal=clientSecret="${AZURE_CLIENT_SECRET}" --namespace "${AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE}"

    ```

4. Generate the cluster configuration. The generated file represents an AKS cluster with 1 system node pool and 1 user node pool. It contains the Cluster API resources, AzureManagedControlPlane, AzureManagedCluster, and AzureManagedMachinePool, that map to the AKS cluster and its node pools.

    ```bash

    clusterctl generate cluster ${CLUSTER_NAME} \
    --kubernetes-version ${KUBERNETES_VERSION} \
    --worker-machine-count=${WORKER_MACHINE_COUNT} \
    --infrastructure azure:v1.13.1 \
    --flavor aks \
    > "generated/${CLUSTER_NAME}.yaml"

    ```

5. Open the file to review the contents.

    ```bash

    code "generated/${CLUSTER_NAME}.yaml"

    ```

6. Apply the workload cluster:

    ```bash

    kubectl apply -f "generated/${CLUSTER_NAME}.yaml"

    ```

7. Access the workload AKS cluster:

    ```bash

    # validate the workload cluster
    kubectl get cluster

    # validate cluster and its resources
    clusterctl describe cluster $CLUSTER_NAME

    ```

8. While the cluster is being provisioned, open the Cluster API Visualizer app to view the current state of your clusters.
  In the "PORTS" tab, click the "Open in Browser" button for the visualizer app.
  ![Open Cluster API Visualizer](/images/open-capi-visualizer.png)

9. After the control plane node is up and running, we can retrieve the workload cluster Kubeconfig:

    ```bash

    clusterctl get kubeconfig $CLUSTER_NAME > "generated/$CLUSTER_NAME.kubeconfig"

    # update KUBECONFIG so kubectl can access the different config files.
    # useful for easily switching kube contexts
    if [ ! "$KUBECONFIG" ];
    then
        export KUBECONFIG=~/.kube/config
    fi
    export KUBECONFIG="${KUBECONFIG}:/workspaces/capi-in-codespaces/generated/${CLUSTER_NAME}.kubeconfig"

    # verify kubectl has access to the new context
    kubectl config get-contexts

    ```

10. After a short while, nodes should be running and in `Ready` state, check the status of workload cluster by running:

    ```bash

    kubectl --context=$CLUSTER_NAME get nodes

    ```

## Challenge

Now create another cluster on your own. In the new cluster, try using different values for one or more of the items below.

- Kubernetes version
- Nodepool VM SKU
- Azure location
- Azure resource group

## Next

Continue with [Add a NodePool](./3-add-nodepool.md) lab. This lab will walk you through adding an additional NodePool to provisioned AKS cluster.
