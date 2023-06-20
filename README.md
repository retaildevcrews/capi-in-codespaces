# capi-in-codespaces overview

This repository leverages GitHub Codespaces to setup a Cluster API management cluster using [kind](https://kind.sigs.k8s.io/), allowing the user to provision other kubernetes workload clusters using the `Docker` and `Azure` infrastructure providers.

The goal of this repository is to provide an environment that accelerates a user's ability to start using Cluster API for managing AKS clusters.   The repository contains guided hands-on learning scenarios to familiarize users with Cluster API. The different scenarios include optional challenges to help you further explore the capabilities of Cluster API and AKS.

![Cluster API Visualizer](/images/capi-visualizer.png)

## What is Cluster API?

Cluster API is a Kubernetes sub-project focused on providing declarative APIs and tooling to simplify provisioning, upgrading, and operating multiple Kubernetes clusters.

One benefit of Cluster API is a common interface for managing Kubernetes clusters across different infrastructure providers like Azure, AWS, GCP, and more. This allows users to manage their multi-cloud Kubernetes clusters in a consistent way from a single control plane. While there are other tools that can be use to provision clusters, like Terraform, Ansible, or Azure Service Operator, Cluster API provides common cluster management tasks via providers that can be used across different types of clusters.

A diagram showing the different components can be found [here](https://cluster-api.sigs.k8s.io/user/concepts.html).

[Additional Cluster API documentation](https://cluster-api.sigs.k8s.io/)

## Get started by opening this repo in CodeSpaces

- Click the Code button
- Click the Codespaces tab
- Click the "Create codespace on main" button

![Create a codespace](/images/create-codespace.png)

> **Note**
> If you're using an Azure Subscription with [conditional access policies](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview) that require Azure Active Directory access from a managed device, then connect to the newly created Codespace with VS Code Desktop running on a managed device.

![Open Codespace command palette](/images/open-command-palette.png)

![Open in VS Code Desktop](/images/open-in-vscode-desktop.png)

## Cluster API Components

### Cluster API controllers

Cluster API has a number of controllers, both in the core Cluster API and the reference providers, which move the state of the cluster toward some defined desired state through the process of controller reconciliation.

Each controller has a set of responsibilities when managing a cluster. For example, the [Cluster controller](https://cluster-api.sigs.k8s.io/developer/architecture/controllers/cluster.html) is responsible for populating common fields on the cluster CRD like the cluster status and API server endpoint. Cluster API is able to retrieve information about clusters through references to provider specific CRDs. These providers and their CRDs also have similar controllers that are responsible for managing the actual state of the cluster infrastructure.

A list of the controllers can be found [here](https://cluster-api.sigs.k8s.io/developer/architecture/controllers.html) with details on the control loop of each controller.

### Cluster API providers

[Providers](https://cluster-api.sigs.k8s.io/reference/glossary.html#provider) are responsible for the different aspects of cluster provisioning, each with specific technology or cloud implementations. For example, the Azure infrastructure provider can create virtual machines, Kubeadm control plane provider can initialize the Kubernetes control plane on the VMs, and the Kubeadm bootstrap provider can transform remaining VMs into Kubernetes nodes and join them to the cluster.

A list of Cluster API providers can be found [here](https://cluster-api.sigs.k8s.io/reference/providers.html).

Details on the Cluster API contract that providers need to follow can be found [here](https://cluster-api.sigs.k8s.io/developer/providers/contracts.html).

### Cluster API CRDs

Kubernetes clusters are described in cluster API as a combination of general Cluster API CRDs and provider specific CRDs. These CRDs represent the different parts of a Kubernetes cluster. For example, the cluster at a high level, the control plane, nodes, node pools, bootstrap configuration, etc.

A diagram of the CRDs and their relationships can be found [here](https://cluster-api.sigs.k8s.io/developer/crd-relationships.html).

For AKS, details of the Azure provider CRDs can be found [here](https://capz.sigs.k8s.io/topics/managedcluster.html#specification).

## Cluster API Visualizer

To help visualize the different components being managed by Cluster API, the labs leverage cluster-api-visualizer UI:
[Cluster API Visualizer](https://github.com/Jont828/cluster-api-visualizer#readme)

To initiate the visualizer for use run the following command:

```bash

# Add visualizer app to management cluster
make capi-visualizer

```

To open the visualizer ui go to the "PORTS" tab in codespaces and click the "Open in Browser" button for the visualizer app.

![Open Cluster API Visualizer](images/open-capi-visualizer.png)

## Labs

Lab 1 can be completed with only access to GitHub Codespaces. To complete the rest of the labs, you will need access to an Azure Subscription with permissions to create a Service Principal.

> **Note**
> Labs should be completed in order, starting from Lab 1

| Lab  | Description |
| ------------- | -------- |
| [Lab 1](./docs/1-kind-cluster.md) | Provision a kind cluster using CAPI and the CAPD provider|
| [Lab 2](./docs/2-managed-aks-cluster.md)| Provision AKS Cluster using CAPI and the Azure Provider |
| [Lab 3](./docs/3-add-nodepool.md) | Add a node pool to an AKS Cluster using CAPI and the Azure Provider |
| [Lab 4](./docs/4-upgrade-k8s.md) | Upgrade AKS control plane and node pools |
| [Lab 5](./docs/5-configure-custom-cluster.md) | Create custom clusters with custom templates |

## Next

Start [Lab 1 - Provision a kind cluster using CAPI and the CAPD provider](./docs/1-kind-cluster.md). This lab will walk you through provsioning a kind cluster using CAPD.
