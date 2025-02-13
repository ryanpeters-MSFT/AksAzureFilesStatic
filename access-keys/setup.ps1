$GROUP = "rg-aks-files"
$CLUSTER = "filescluster"
$STORAGE_ACCOUNT = "storageaccount0116252"
$STORAGE_ACCOUNT_SHARE = "data"

# create the group
az group create -n $GROUP -l eastus2

# create the storage account and share
az storage account create -n $STORAGE_ACCOUNT -g $GROUP --sku Standard_LRS
az storage share create -n $STORAGE_ACCOUNT_SHARE --account-name $STORAGE_ACCOUNT

# create cluster
az aks create -n $CLUSTER -c 1 -g $GROUP

# get credentials
az aks get-credentials -g $GROUP -n $CLUSTER --overwrite-existing

# get the access key and create the secret
$STORAGE_KEY = az storage account keys list -g $GROUP --account-name $STORAGE_ACCOUNT --query "[0].value" -o tsv
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT --from-literal=azurestorageaccountkey=$STORAGE_KEY

# apply scripts
kubectl apply -f .\pv.yaml -f .\pvc.yaml -f .\deployment.yaml