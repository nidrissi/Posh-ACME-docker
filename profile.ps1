if ($env:MSI_SECRET) {
    Disable-AzContextAutosave -Scope Process | Out-Null
    Connect-AzAccount -Identity

    $Subscription = Get-AzSubscription
    $AccessToken = Get-AzAccessToken
    $PluginArguments = @{
        AZSubscriptionId = $Subscription.Id
        AZAccessToken    = $AccessToken.Token
    }
} else {
    exit 1
}

Set-PAServer LE_STAGE
