[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory, HelpMessage = "Resource group for the deployment.")]
    [string]
    $ResourceGroup,
    [Parameter(Mandatory, HelpMessage = "Zones to grant access to.")]
    [string[]]
    $ZoneNames
)

# Deploy
Write-Verbose "Starting the deployment."
$Deployment = New-AzResourceGroupDeployment -Name 'Posh-ACME' -ResourceGroupName $ResourceGroup -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json

# Get the Container Group
if ($Deployment.Outputs) {
    Write-Verbose "Getting the container group"
    $ContainerGroup = Get-AzContainerGroup -ResourceGroupName $ResourceGroup -Name $Deployment.Outputs.container.Value

    foreach ($ZoneName in $ZoneNames) {
        Write-Verbose "Working on zone $ZoneName."
        # The zone
        $ZoneResource = Get-AzResource -Name $ZoneName -ResourceType 'Microsoft.Network/dnszones'
        $ZoneScope = $ZoneResource.ResourceId
        Write-Verbose "Zone ID: $ZoneScope"

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
    }

    # Start the container, for real this time
    Write-Verbose "Starting the container."
    Invoke-AzResourceAction -ResourceId $ContainerGroup.Id -Action start -Force
    # I should investigate...
    Write-Warning @"
Ignore the previous error message if it says:
> No HTTP resource was found that matches the request URI
"@

    $ConnectionName = $Deployment.Outputs.apiConnection.value
    Write-Verbose "Getting connection $ConnectionName"
    $Connection = Get-AzResource -ResourceType 'Microsoft.Web/connections' -ResourceGroupName $ResourceGroup -ResourceName 'aci'
    $Status = $Connection.Properties.Statuses[0].status
    if ($Status -ne 'Connected') {
        $LogicApp = $Deployment.Outputs.logicAppName.Value
        # I should find a way to do this automatically
        Write-Warning @"
API status is $Status.
It may need authenticating:
- Go to the portal;
- Open the Logic App $LogicApp;
- In the designer, click on the action;
- Modify the connection and authorize it.
"@
    }
    else {
        Write-Verbose "API connection already established."
    }
}
else {
    Write-Error "No outputs!"
    exit 1
}
