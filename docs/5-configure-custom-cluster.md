# Configure more cluster configurations using custom templates

When creating the AKS cluster in previous labs, we used the AKS template that is included with Cluster API Provider Azure. This template is good when you're starting with Cluster API, but it may not meet all of your needs. In this lab, we'll walk through how to use a custom template to create a cluster with more advanced configurations, like creating a private cluster.

## Prerequisites

If you have not already done so, complete the [prerequisites section](./2-managed-aks-cluster.md#prerequisites) in AKS lab including [setting up credentials for Cluster API](./2-managed-aks-cluster.md#setup-service-principal-and-credentials).

## Lab Steps

1. Set a new name for this latest cluster that will be created.

    ```bash

    # set a cluster name
    export CLUSTER_NAME=capz-$(echo $GITHUB_USER | tr '[:upper:]' '[:lower:]')-private-aks
    export WORKER_MACHINE_COUNT=1

    # validate valid kubernetes version for a given location by running
    az aks get-versions -l eastus -o table

    # set the desired kubernetes version to a one that has available upgrades
    export KUBERNETES_VERSION="v1.26.0"

    # Azure values
    export AZURE_LOCATION="eastus"
    export AZURE_RESOURCE_GROUP=$CLUSTER_NAME-rg

    ```

2. Set environment variables for the custom AKS template to customize the type of cluster you want to create. For this lab, we'll be creating a private cluster. The template also includes some additional configurations that show examples of how to further customize a cluster with more advanced settings.

    ```bash

    # Configure public or private cluster by setting this variable to true or false.
    export PRIVATE_CLUSTER=true

    # Configure the Node Pool kubelet to toggle quota enforcement for containers that specify CPU limits.
    # Acceptable values are true or false, defaults to true when not specified.
    # See https://capz.sigs.k8s.io/topics/managedcluster.html#aks-node-pool-kubelet-custom-configuration for more details.
    export AZURE_NODE_KUBELET_CPUCFSQUOTA=false

    # Customize Linux OS configs for the Node Pool, in this case, the maximum number of open files permitted.
    # The range of acceptable values is 8192 to 12000500, defaults to 709620 when not specified.
    # See https://capz.sigs.k8s.io/topics/managedcluster.html#os-configurations-of-linux-agent-nodes-aks for more details.
    # This setting is intentionally different from the default simply to make it easy to validate the custom configuration on the cluster.
    export AZURE_NODE_LINUXOSCONFIG_FSFILEMAX=709621

    ```

3. Generate the yaml from the custom AKS template using clusterctl. This is similar to the previous labs where node pools were added to the cluster. Use the `--from` flag to specifiy the location of the custom template. Templates can be sourced from Kubernetes ConfigMaps, URLs, local files, or standard input. More information can be found here, <https://cluster-api.sigs.k8s.io/clusterctl/commands/generate-cluster.html>

    ```bash

    # use clusterctl to generate yaml from the custom template
    clusterctl generate yaml --from ./templates/custom-aks.yaml > "generated/${CLUSTER_NAME}.yaml"

    # view generated yaml
    code "generated/${CLUSTER_NAME}.yaml"

    ```

4. Create the custom private cluster by applying the generated yaml to the management cluster.

    ```bash

    # apply cluster yaml
    kubectl apply -f "generated/${CLUSTER_NAME}.yaml"

    ```

5. View the state of the cluster. When the cluster is showing `True` in the Ready column, move on to the next step.

    ```bash

    # validate the workload cluster
    kubectl get cluster

    # validate cluster and its resources
    clusterctl describe cluster $CLUSTER_NAME

    ```

    Example output from `clusterctl describe cluster` command:
    ![Example output from describe command](/images/capz-private-aks-example.png)

6. After Cluster API reports that the cluster is ready, validate you can connect to the cluster. Because this is a private cluster, you will need to use an alternative method to communicate with the API server. This lab uses `az aks command invoke`. More information can be found here for options to connect to a private cluster, <https://learn.microsoft.com/en-us/azure/aks/private-clusters#options-for-connecting-to-the-private-cluster>.

    ```bash

    az aks command invoke \
        --resource-group $AZURE_RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --command "kubectl get nodes"

    ```

7. Validate that the custom kubelet and linux os configurations were applied to the node pool.

    ```bash

    # Check the kubelet config
    az aks show \
        --name $CLUSTER_NAME \
        --resource-group $AZURE_RESOURCE_GROUP \
        --query "agentPoolProfiles[0].kubeletConfig.cpuCfsQuota"

    # Check the linux os config
    az aks show \
        --name $CLUSTER_NAME \
        --resource-group $AZURE_RESOURCE_GROUP \
        --query "agentPoolProfiles[0].linuxOsConfig.sysctls.fsFileMax"

    ```
