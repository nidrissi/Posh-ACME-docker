[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Email,
    [Parameter(Mandatory)]
    [string]
    $KeyVault,
    [Parameter(Mandatory)]
    [string]
    $Domain,
    [Parameter(Mandatory)]
    [string]
    $SubscriptionId,
    # Parameter help description
    [Parameter(Mandatory)]
    [string]
    $StorageAccount,
    [Parameter(Mandatory)]
    [string]
    $StorageAccountKey
)

az container create --resource-group 'rg-Posh-ACME' --name 'aci-posh-acme' --image nidrissi/posh-acme:0.4.0 --azure-file-volume-account-name $StorageAccount --azure-file-volume-account-key $StorageAccountKey --azure-file-volume-share-name 'acishare' --azure-file-volume-mount-path "/mnt/acishare" --assign-identity --environment-variables "MyEmail=$Email" "My_KeyVault=$KeyVault" "My_Domain=$Domain" "My_SubscriptionId=$SubscriptionId" --location 'francecentral' --restart-policy Never
