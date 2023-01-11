# Provision AKS Cluster using CAPZ

Cluster API Provider Azure (CAPZ) experimentally supports managing Azure Kubernetes Service (AKS) clusters. CAPZ implements this with three custom resources:

- AzureManagedControlPlane
- AzureManagedCluster
- AzureManagedMachinePool

The combination of `AzureManagedControlPlane`/`AzureManagedCluster` corresponds to provisioning an AKS cluster. `AzureManagedMachinePool` corresponds one-to-one with AKS node pools.

## Deploy with clusterctl

- A clusterctl flavor exists to deploy an AKS cluster with CAPZ. This flavor requires the following environment variables to be set before executing clusterctl.

  ```bash

  # Kubernetes values
  export CLUSTER_NAME=capz-$(echo $GITHUB_USER | tr '[:upper:]' '[:lower:]')-aks
  export CONTROL_PLANE_MACHINE_COUNT=1
  export WORKER_MACHINE_COUNT=1
  # validate valid kubernetes version for a given location by running
  # az aks get-versions -l eastus
  export KUBERNETES_VERSION="v1.25.2"

  ```

  ```bash

  # Azure values
  export AZURE_LOCATION="eastus"
  export AZURE_RESOURCE_GROUP=$CLUSTER_NAME-rg

  ```

- An Azure Service Principal is needed for deploying Azure resources. The below instructions utilize [environment-based authentication](https://docs.microsoft.com/en-us/go/azure/azure-sdk-go-authorization#use-environment-based-authentication).

  > NOTE: All the required environment variables are set as part of the devcontainer setup. For more information about authorization, AAD, or requirements for Azure, visit the [Azure provider prerequisites document](https://capz.sigs.k8s.io/topics/getting-started.html#prerequisites)

  ```bash

   # validate env variables for authentication
   env | grep AZURE

  ```

  - AZURE_SUBSCRIPTION_ID
  - AZURE_SUBSCRIPTION_ID_B64
  - AZURE_CLIENT_ID
  - AZURE_CLIENT_ID_B64
  - AZURE_CLIENT_SECRET
  - AZURE_CLIENT_SECRET_B64
  - AZURE_TENANT_ID
  - AZURE_TENANT_ID_B64
  - AZURE_CLUSTER_IDENTITY_SECRET_NAME
  - AZURE_NODE_MACHINE_TYPE (Set as `Standard_A2_v2` for this lab)
  - AZURE_CONTROL_PLANE_MACHINE_TYPE (Set as `Standard_A2_v2` for this lab)

  Managed cluster also requires AKS feature flags set in order to provision cluster using AKS flavor:

  ```bash

  echo $EXP_MACHINE_POOL
  echo $EXP_AKS

  ```

- Validate Cluster Identity secret in kind cluster which includes the password of the Service Principal identity created in Azure. This secret will be referenced by the AzureClusterIdentity used by the AzureCluster.

  ```bash

  kubectl get secret $AZURE_CLUSTER_IDENTITY_SECRET_NAME
  # if not set, create a new secret by executing this command:
  # kubectl create secret generic "${AZURE_CLUSTER_IDENTITY_SECRET_NAME}" --from-literal=clientSecret="${AZURE_CLIENT_SECRET}" --namespace "${AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE}"

  ```

- Generate the cluster configuration:

  ```bash

  clusterctl generate cluster ${CLUSTER_NAME} \
  --kubernetes-version ${KUBERNETES_VERSION} \
  --control-plane-machine-count=${CONTROL_PLANE_MACHINE_COUNT} \
  --worker-machine-count=${WORKER_MACHINE_COUNT} \
  --infrastructure azure:v1.6.1 \
  --flavor aks \
  > ${CLUSTER_NAME}.yaml

  ```

- Apply the workload cluster:

  ```bash

  kubectl apply -f ${CLUSTER_NAME}.yaml

  ```

- Access the workload AKS cluster:

  ```bash

  # validate the workload cluster
  kubectl get cluster

  # validate cluster and its resources
  clusterctl describe cluster $CLUSTER_NAME

  ```

- While the cluster is being provisioned, open the Cluster API Visualizer app to view the current state of your clusters.
  In the "PORTS" tab, click the "Open in Browser" button for the visualizer app.
  ![Open Cluster API Visualizer](/images/open-capi-visualizer.png)

- After the control plane node is up and running, we can retrieve the workload cluster Kubeconfig:

  ```bash

  clusterctl get kubeconfig $CLUSTER_NAME > $CLUSTER_NAME.kubeconfig

  # update KUBECONFIG so kubectl can access the different config files.
  # useful for easily switching kube contexts
  export KUBECONFIG="${KUBECONFIG}:/workspaces/capi-in-codespaces/${CLUSTER_NAME}.kubeconfig"

  ```

- After a short while, nodes should be running and in `Ready` state, check the status of workload cluster by running:

  ```bash

  kubectl --context=$CLUSTER_NAME get nodes

  ```

## Challenge

Now create another cluster on your own. In the new cluster, try using different values for one or more of the items below.

- Kubernetes version
- Nodepool VM SKU
- Azure location
- Azure resource group