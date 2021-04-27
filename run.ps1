if (Test-Path $env:POSHACME_HOME/.wait) {
    # if this is the first time, manually wait
    Write-Error "I was told to wait!"
    exit 1
}

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
Set-PAServer LE_STAGE

# Create account if none exists
if (-not (Get-PAAccount)) {
    New-PAAccount -Contact $env:My_Email -AcceptTOS
}

# A KeyVault certificate's name cannot contain a dot
function Import-MyCertificates {
    $SanitizedDomain = $env:My_Domain -replace '\.', '-'

    $Certificate = Get-PACertificate
    Import-AzKeyVaultCertificate -VaultName $env:My_KeyVault -Name "$SanitizedDomain-FullChain" -FilePath $Certificate.PfxFullChain -Password $Certificate.PfxPass

    Import-AzKeyVaultCertificate -VaultName $env:My_KeyVault -Name "$SanitizedDomain-OnlyCert" -FilePath $Certificate.PfxFile -Password $Certificate.PfxPass
}

if (-not (Get-PACertificate -MainDomain $env:My_Domain)) {
    # If no certificate exists, create it...
    New-PACertificate -Plugin Azure -PluginArgs $PluginArguments -Domain ($env:My_Domain, ("*.{0}" -f $env:My_Domain))
    #...and import the key
    Import-MyCertificates
}
else {
    if (Submit-Renewal) {
        # Only import if there was a renewal
        Import-MyCertificates
    }
}
