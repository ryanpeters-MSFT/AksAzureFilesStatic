# AKS using Azure Files (Static)

This repository shows examples of configuring and accessing a static Azure Files share from AKS using both Access Keys and Managed Identity. The setup script will create a storage account and a SMB share for reference by a `PersistentVolume`. 

| Mode | Description | PV Characteristics |
| - | - | - |
| Access Keys | Uses a static key that is attached to the storage account. This key is stored as a Kubernetes secret and is referenced in the PV when connecting to the backing volume. | Creates a secret containing the access key and stores as a secret. This secret is referenced by the PV using the `nodeStageSecretRef` section. |
| Managed Identity | Avoids the use of storing and managing a key to access the file share. The roles `Storage Account Key Operator Service Role` and `Reader` are used and assigned to grant access to the share from the kubelet identity. | No secrets are required. Instead, it references the `storageAccount` and `resourceGroup` under the `volumeAttributes` section. |

## Invocation

Deployment scripts are in both the [`access-keys`](./access-keys/) and [`managed-identity`](./managed-identity/) folders and are very similar except for the configuration of the keys and roles, respectively. 

```powershell
# invoke the setup script (change to appropriate directory)
.\setup.ps1

# apply scripts
kubectl apply -f .\pv.yaml -f .\pvc.yaml -f .\deployment.yaml
```

This will create a deployment with 2 replicas (any number can be used) and mounts the Azure File share at the path `/filedata` inside of the pods. You can then `exec` into the pod and view/write/read content from this folder. 

```powershell
# list the pods for the deployment
kubectl get pods -l app=nginx

# select a pod and exec into the container
kubectl exec -it nginx-abcdef1234-abc12 -- bash

# from within the container
touch /filedata/hello.dat
```