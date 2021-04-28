[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)] [string] $Email,
    [Parameter(Mandatory)] [string] $ResourceGroupName,
    [Parameter(Mandatory)] [string] $ContainerGroupName,
    [Parameter(Mandatory)] [string] $StorageAccount,
    [Parameter(Mandatory)] [string] $KeyVault,
    [Parameter(Mandatory)] [string] $Domain
)

# Get the password to the storage account and make a credential out of it
$Password = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccount)[0].Value
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($StorageAccount, $SecurePassword)

$Subscription = Get-AzSubscription

$Arguments = @{
    ResourceGroupName                = $ResourceGroupName;
    Name                             = $ContainerGroupName;
    Image                            = 'nidrissi/posh-acme:0.4.0';
    AzureFileVolumeShareName         = 'acishare';
    AzureFileVolumeMountPath         = '/mnt/acishare';
    AzureFileVolumeAccountCredential = $Credential;
    AssignIdentity                   = $true;
    Location                         = 'francecentral';
    RestartPolicy                    = 'Never';
    EnvironmentVariable              = @{
        My_Email          = $Email;
        My_KeyVault       = $KeyVault;
        My_Domain         = $Domain;
        My_SubscriptionId = $Subscription.Id
    }
}

New-AzContainerGroup @Arguments
