. /opt/acme-posh/profile.ps1

$Domains = Get-PACertificate | Foreach-Object { $_.Subject -replace "^CN=", "" }

foreach ($domain in $Domains) {
    if (Submit-Renewal -MainDomain $domain) {
        /opt/acme-posh/import.ps1 -Domain $env:My_Domain
    }
}
