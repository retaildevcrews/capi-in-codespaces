# capi-in-codespaces

CAPI/CAPZ in GitHub Codespaces

## Overview

This is a template that will setup Cluster API using kind/k3d to provision other kubernetes clusters in a GitHub Codespaces using `Docker` infrastructure provider.

## Cluster API overview

<https://cluster-api.sigs.k8s.io/>

> Cluster API is a Kubernetes sub-project focused on providing declarative APIs and tooling to simplify provisioning, upgrading, and operating multiple Kubernetes clusters.

One benefit of Cluster API is a common interface for managing Kubernetes clusters across different infrastructure providers like Azure, AWS, GCP, and more.

A diagram showing the different components can be found here. <https://cluster-api.sigs.k8s.io/user/concepts.html>.

### Cluster API controllers

> Cluster API has a number of controllers, both in the core Cluster API and the reference providers, which move the state of the cluster toward some defined desired state through the process of controller reconciliation.

Each controller has a set of responsibilities when managing a cluster. For example, the [Cluster controller](https://cluster-api.sigs.k8s.io/developer/architecture/controllers/cluster.html) is responsible to populating common fields on the cluster CRD like the cluster status and API server endpoint. Cluster API is able to retrieve information about clusters through references to provider specific CRDs. These providers and their CRDs also have similar controllers that are responsible for managing the actual state of the cluster infrastructure.

A list of the controllers can be found here with details on the control loop of each controller. <https://cluster-api.sigs.k8s.io/developer/architecture/controllers.html>.

### Cluster API providers

<https://cluster-api.sigs.k8s.io/reference/glossary.html#provider>

Providers are responsible for the different aspects of cluster provisioning, each with specific technology or cloud implementations. For example, the Azure infrastructure provider can create virtual machines, Kubeadm control plane provider can initialize the Kubernetes control plane on the VMs, and the Kubeadm bootstrap provider can transform remaining VMs into Kubernetes nodes and join them to the cluster.

A list of Cluster API providers can be found here. <https://cluster-api.sigs.k8s.io/reference/providers.html>.

Details on the Cluster API contract that providers need to follow can be found here. <https://cluster-api.sigs.k8s.io/developer/providers/contracts.html>.

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

- A workload cluster configuraton with 1 control plane and 1 worker machine is generated as part of the Codespaces setup. It creates a YAML file named `capi-quickstart.yaml` with a predefined list of Cluster API objects; Cluster, Machines, Machine Deployments, etc.

  > When kind management cluster is reset to initial state, transform the kubernetes cluster in to management cluster by running:
  >
  > ```bash
  >
  > export CLUSTER_TOPOLOGY=true
  > clusterctl init --infrastructure docker
  >
  > ```
  >
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

  # update KUBECONFIG so kubectl can access the different config files.
  # useful for easily switching kube contexts
  export KUBECONFIG=~/.kube/config:/workspaces/capi-in-codespaces/capi-quickstart.kubeconfig

  kubectl config rename-context capi-quickstart-admin@capi-quickstart capi-quickstart

  ```

- The control plane won’t be `Ready` until we install a CNI, deploy a CNI solution by running:

   ```bash

   kubectl --context=capi-quickstart \
   apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml

   ```

  After a short while, nodes should be running and in `Ready` state, check the status of workload cluster by running:

  ```bash

  kubectl --context=capi-quickstart get nodes

  ```

## Clean up

- Once done experimenting, delete the workload cluster and it's kubeconfig:

  ```bash

  kubectl delete cluster capi-quickstart
  rm capi-quickstart.kubeconfig
  unset KUBECONFIG

  ```

> NOTE: For experimental and educational purpose, follow [this quickstart](https://cluster-api.sigs.k8s.io/user/quick-start.html) for the manual setup of CAPI and workload clusters
