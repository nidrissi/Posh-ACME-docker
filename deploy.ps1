[CmdletBinding(SupportsShouldProcess)]
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
Write-Verbose "Starting the deployment."
$Deployment = New-AzResourceGroupDeployment -Name 'Posh-ACME' -ResourceGroupName $ResourceGroup -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
# Immediately stop the container

# Get the Container Group
if ($Deployment.Outputs) {
    Write-Verbose "Getting the container group"
    $ContainerGroup = Get-AzContainerGroup -ResourceGroupName $ResourceGroup -Name $Deployment.Outputs.container.Value
    Write-Verbose "Stopping the container."
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
    Write-Verbose "Checking if role is assigned."
    if (-not (Get-AzRoleAssignment @RoleArguments)) {
        Write-Verbose "Assigning role."
        New-AzRoleAssignment @RoleArguments
    }
    else {
        Write-Verbose "Not assigning role: already assigned."
    }

    # Start the container, for real this time
    Write-Verbose "Starting the container."
    Invoke-AzResourceAction -ResourceId $ContainerGroup.Id -Action start -Force
    # I should investigate...
    Write-Warning @"
Ignore the previous error message if it says:
> No HTTP resource was found that matches the request URI
"@
}
else {
    Write-Warning "No outputs!"
}
