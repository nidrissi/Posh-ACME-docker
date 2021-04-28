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
$Deployment = New-AzResourceGroupDeployment -Name 'Posh-ACME' -ResourceGroupName $ResourceGroup -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
# Immediately stop the container

# Get the Container Group
$ContainerGroup = Get-AzContainerGroup -ResourceGroupName $ResourceGroup -Name $Deployment.Outputs.container.Value
Invoke-AzResourceAction -ResourceId $ContainerGroup.Id -Action stop -Force

# The zone
$ZoneResource = Get-AzResource -ResourceGroupName $ZoneResourceGroup -Name $ZoneName
$ZoneScope = $ZoneResource.ResourceId

# Roles
$RoleArguments = @{
    ObjectId           = $ContainerGroup.Identity.PrincipalId;
    RoleDefinitionName = "DNS Zone Contributor";
    Scope              = $ZoneScope
}
if (-not (Get-AzRoleAssignment @RoleArguments)) {
    New-AzRoleAssignment @RoleArguments
}

# Start the container, for real this time
Invoke-AzResourceAction -ResourceId $ContainerGroup.Id -Action start -Force
