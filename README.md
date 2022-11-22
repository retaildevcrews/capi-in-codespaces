# capi-in-codespaces
CAPI/CAPZ in GitHub Codespaces

## Overview

This is a template that will setup Cluster API using kind/k3d to provision other kubernetes clusters in a GitHub Codespaces using `Docker` infrastructure provider.

## kind

Cluster API requires an existing Kubernetes cluster accessible via kubectl. During the installation process the Kubernetes cluster will be transformed into a management cluster by installing the Cluster API provider components, so it is recommended to keep it separated from any application workload.

- A management cluster is created and initialized with CAPI/CAPD components as part of the Codespaces setup:

  ```bash

  kubectl get pods -A

  ```

- The `clusterctl` CLI tool handles the lifecycle of a Cluster API management cluster. Ensure an up-to-date version of the CLI installed to your GH Codespaces:

  ```bash

  clusterctl version

  ```

- A workload cluster configuraton with 1 control plane and 1 worker machine is generated as part of Codespaces setup. It creates a YAML file named `capi-quickstart.yaml` with a predefined list of Cluster API objects; Cluster, Machines, Machine Deployments, etc.

  > If needed, regenerate the cluster configuration by running:
  >
  > ```bash
  >
  > clusterctl generate cluster capi-quickstart --flavor development \
  > --kubernetes-version v1.25.0 \
  > --control-plane-machine-count=1 \
  > --worker-machine-count=1 \
  > capi-quickstart.yaml
  >
  > ```

- When ready, run the following command to apply the cluster manifest:

  ```bash

  kubectl apply -f capi-quickstart.yaml

  ```

- Access the workload cluster:

  ```bash

  # validate the workload cluster
  kubectl get cluster

  # validate cluster and its resources
  clusterctl describe cluster capi-quickstart

  # verify the control plane is up
  kubectl get kubeadmcontrolplane

  ```

- After the control plane node is up and running, we can retrieve the workload cluster Kubeconfig:

  ```bash

  clusterctl get kubeconfig capi-quickstart > capi-quickstart.kubeconfig

  ```

- The control plane won’t be `Ready` until we install a CNI, deploy a CNI solition by running:

   ```bash

   kubectl --kubeconfig=./capi-quickstart.kubeconfig \
   apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml

   ```

  After a short while, nodes should be running and in `Ready` state, check the status of workload cluster by running:

  ```bash

  kubectl --kubeconfig=./capi-quickstart.kubeconfig get nodes

  ```

## Clean up

- Delete the workload cluster and it's kubeconfig:

  ```bash

  kubectl delete cluster capi-quickstart
  rm capi-quickstart.kubeconfig

  ```
