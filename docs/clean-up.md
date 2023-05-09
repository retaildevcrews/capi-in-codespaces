# Clean up

Once done experimenting, delete the workload clusters and Azure resources.

```bash

# delete docker cluster
kubectl delete cluster capi-quickstart

# list the rest of the AKS clusters and delete them
kubectl get cluster -A
kubectl delete cluster <replace with cluster name>

unset KUBECONFIG

# delete az resource group
az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
az group delete --name $AZURE_RESOURCE_GROUP

```
