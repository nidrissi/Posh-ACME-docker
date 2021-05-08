$ErrorActionPreference = "Stop"

# Connect to the MSI
Disable-AzContextAutosave -Scope Process
Connect-AzAccount -Identity

# Get an access token for Posh-ACME
$AccessToken = Get-AzAccessToken
$PluginArguments = @{
    AZSubscriptionId = $env:My_SubscriptionId
    AZAccessToken    = $AccessToken.Token
}

# Set the server. Possible values: LE_PROD (production), LE_STAGE (staging), etc
Set-PAServer LE_PROD

# Create account if none exists
if (-not (Get-PAAccount)) {
    New-PAAccount -Contact $env:My_Email -AcceptTOS
}

# $env:My_Domains contains a ';'-separated list of domains
$Domains = $env:My_Domains -split ' *; *'

# A KeyVault certificate's name cannot contain a dot
function Import-MyCertificates {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Domain,
        [Parameter()]
        [boolean]
        $All
    )

    $DomainsToImport = @()
    if ($All) {
        $DomainsToImport = $Domains
    }
    elseif ($Domain) {
        $DomainsToImport = @($Domain)
    }
    else {
        Write-Error "One of -All or -Domain must be specified"
        exit 1
    }

    foreach ($CurrentDomain in $DomainsToImport) {
        # A KeyVault certificate's name cannot contain a dot
        $SanitizedDomain = $env:Domain -replace '\.', '-'

        # Get the certificate info for the domain
        $Certificate = Get-PACertificate -MainDomain $CurrentDomain

        # Import both the full chain and the certificate
        Import-AzKeyVaultCertificate -VaultName $env:My_KeyVault -Name "$SanitizedDomain-FullChain" -FilePath $Certificate.PfxFullChain -Password $Certificate.PfxPass

        Import-AzKeyVaultCertificate -VaultName $env:My_KeyVault -Name "$SanitizedDomain-OnlyCert" -FilePath $Certificate.PfxFile -Password $Certificate.PfxPass
    }
}

# On the first run, we may not have certificates already
foreach ($CurrentDomain in $Domains) {
    if (-not (Get-PACertificate -MainDomain $CurrentDomain)) {
        # If no certificate exists, create it...
        New-PACertificate -Plugin Azure -PluginArgs $PluginArguments -Domain ($CurrentDomain, ("*.{0}" -f $CurrentDomain))
        #...and import the key
        Import-MyCertificates -Domain $CurrentDomain
    }
}

# On subsequent runs, renew and import everything if there was a renewal
if (Submit-Renewal) {
    # Only import if there was a renewal
    Import-MyCertificates -All
}
