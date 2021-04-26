. /opt/acme-posh/profile.ps1

if (-not (Get-PAAccount)) {
    New-PAAccount -Contact $env:My_Email -AcceptTOS
}

if (-not (Get-PACertificate -MainDomain $env:My_Domain)) {
    New-PACertificate -Plugin Azure -PluginArgs $PluginArguments -Domain ($env:My_Domain, ("*.{0}" -f $env:My_Domain))
}
/opt/acme-posh/import.ps1 -Domain $env:My_Domain
