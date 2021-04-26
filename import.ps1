[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Domain
)

$SanitizedDomain = $Domain -replace '\.', '-'

if ($Certificate = Get-PACertificate -MainDomain $Domain) {
    Import-AzKeyVaultCertificate -VaultName $env:My_KeyVault -Name "${SanitizedDomain}-fullchain" -FilePath $Certificate.PfxFullChain -Password $Certificate.PfxPass -Verbose
    Import-AzKeyVaultCertificate -VaultName $env:My_KeyVault -Name "${SanitizedDomain}-cert" -FilePath $Certificate.PfxFile -Password $Certificate.PfxPass -Verbose
}
