# Configure more cluster configurations using custom templates

TODO: lab description

## Prerequisites

TODO: list prepreqs if any

## Lab Steps

1. Set a new name for this new cluster that will be created.

    ```bash

    # set a cluster name
    export CLUSTER_NAME=capz-$(echo $GITHUB_USER | tr '[:upper:]' '[:lower:]')-private-aks

    # view cluster name
    echo $CLUSTER_NAME

    ```

2. Set environment variables for the custom AKS template to customize the type of cluster you want to create.

    ```bash

    # configure public or private cluster by setting this variable to true or false
    export PRIVATE_CLUSTER=true

    # use clusterctl to generate yaml from the custom template
    clusterctl generate yaml --from ./templates/custom-aks.yaml > "generated/${CLUSTER_NAME}.yaml"

    ```

3. Create the custom cluster by applying the generated yaml.

    ```bash

    # apply cluster yaml
    kubectl apply -f "generated/${CLUSTER_NAME}.yaml"

    ```

## Challenge

TODO: challenge
