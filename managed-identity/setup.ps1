$GROUP = "rg-aks-files-mi"
$CLUSTER = "filesclustermi"
$STORAGE_ACCOUNT = "storageaccount011625"
$STORAGE_ACCOUNT_SHARE = "data"

# # create the group
az group create -n $GROUP -l eastus2

# create the storage account and share
$STORAGE_RESOURCE_ID = az storage account create -n $STORAGE_ACCOUNT -g $GROUP --sku Standard_LRS -o tsv --query id
az storage share create -n $STORAGE_ACCOUNT_SHARE --account-name $STORAGE_ACCOUNT

# create cluster and get kubelet identity for role assignments
$KUBELET_IDENTITY = az aks create -n $CLUSTER -c 1 -g $GROUP --query identityProfile.kubeletidentity.objectId -o tsv

# get credentials
az aks get-credentials -g $GROUP -n $CLUSTER --overwrite-existing

# grant access to the storage account from the kubelet identity
az role assignment create --assignee $KUBELET_IDENTITY --role "Storage Account Key Operator Service Role" --scope $STORAGE_RESOURCE_ID

# apply scripts
kubectl apply -f .\pv.yaml -f .\pvc.yaml -f .\deployment.yaml