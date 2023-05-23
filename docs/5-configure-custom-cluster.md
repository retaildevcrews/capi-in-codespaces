# Configure more cluster configurations using custom templates

When creating the AKS cluster in previous labs, we used the AKS template that is included with Cluster API Provider Azure. This template is good when you're starting with Cluster API, but it may not meet all of your needs. In this lab, we'll walk through how to use a custom template to create a cluster with more advanced configurations, like creating a private cluster.

## Lab Steps

1. Set a new name for this latest cluster that will be created.

    ```bash

    # set a cluster name
    export CLUSTER_NAME=capz-$(echo $GITHUB_USER | tr '[:upper:]' '[:lower:]')-private-aks

    # view cluster name
    echo $CLUSTER_NAME

    ```

2. Set environment variables for the custom AKS template to customize the type of cluster you want to create. For this lab, we'll be creating a private cluster.

    ```bash

    # configure public or private cluster by setting this variable to true or false
    export PRIVATE_CLUSTER=true

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
