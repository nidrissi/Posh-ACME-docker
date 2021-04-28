[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $ResourceGroup,
    [Parameter(Mandatory)]
    [string]
    $ZoneResourceGroup,
    [Parameter(Mandatory)]
    [string]
    $ZoneName
)

# Deploy
$Deployment = New-AzResourceGroupDeployment -Verbose -Name 'Posh-ACME' -ResourceGroupName $ResourceGroup -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
# Immediately stop the container
Invoke-AzResourceAction -ResourceId $ContainerGroup.Id -Action stop -Force

# Get the Container Group
$ContainerGroup = Get-AzContainerGroup -ResourceGroupName rg-Test -Name $Deployment.Outputs.container.Value

# The zone
$ZoneResource = Get-AzResource -ResourceGroupName $ZoneResourceGroup -Name $ZoneName
$ZoneScope = $ZoneResource.ResourceId

# Roles
New-AzRoleAssignment -ObjectId $ContainerGroup.Identity.PrincipalId -RoleDefinitionName "DNS Zone Contributor" -Scope $ZoneScope

# Start the container, for real this time
Invoke-AzResourceAction -ResourceId $ContainerGroup.Id -Action start -Force
