$GROUP = "rg-aks-files-mi"
$CLUSTER = "filesclustermi"
$STORAGE_ACCOUNT = "storageaccount011625"
$STORAGE_ACCOUNT_SHARE = "data"

# # create the group
az group create -n $GROUP -l eastus2

# create the storage account and share
$STORAGE_RESOURCE_ID = az storage account create -n $STORAGE_ACCOUNT -g $GROUP --sku Standard_LRS -o tsv --query id
az storage share create -n $STORAGE_ACCOUNT_SHARE --account-name $STORAGE_ACCOUNT

# create cluster
az aks create -n $CLUSTER -c 1 -g $GROUP

# get credentials
az aks get-credentials -g $GROUP -n $CLUSTER --overwrite-existing

# get kubelet identity for role assignments
$KUBELET_IDENTITY = az aks show -g $GROUP -n $CLUSTER --query identityProfile.kubeletidentity.objectId -o tsv

# grant access to the storage account from the kubelet identity
az role assignment create --assignee $KUBELET_IDENTITY --role 'Storage Account Key Operator Service Role' --scope $STORAGE_RESOURCE_ID
az role assignment create --assignee $KUBELET_IDENTITY --role 'Reader' --scope $STORAGE_RESOURCE_ID