[CmdletBinding()]
param (
    [Parameter(Position=0,mandatory=$true)]
    [string] $Mode,
    [Parameter(Position=0,mandatory=$true)]
    [string] $OutputFolder,
    [Parameter(Position=0,mandatory=$true)]
    [string] $SubscriptionId,
    [Parameter(Position=0,mandatory=$true)]
    [string] $LAResourceGroup,
    [Parameter(Position=0,mandatory=$true)]
    [string] $LALocation,
    [Parameter(Position=0,mandatory=$true)]
    [string] $WorkSpaceName
)
$token = (Get-AzAccessToken -ResourceUrl "https://management.azure.com") | Select-Object Token -ExpandProperty Token
$subscription_id = $SubscriptionId
# Create the resource group if needed
try {
    Get-AzResourceGroup -Name $LAResourceGroup -ErrorAction Stop
} catch {
    New-AzResourceGroup -Name $LAResourceGroup -Location $LALocation
}
$out = New-AzOperationalInsightsWorkspace -Location $LALocation -Name $WorkspaceName -ResourceGroupName $LAResourceGroup -Force
$workspace_id = $out.ResourceId
if ($Mode -eq "Start"){
    foreach ($line in Get-Content "$OutputFolder\resources.json"){
        $line = ConvertFrom-Json $line
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("x-ms-command-name", "Microsoft_Azure_Monitoring.")
        $headers.Add("Accept-Language", "en")
        $headers.Add("Authorization", "Bearer $token")
        $headers.Add("x-ms-effective-locale", "en.en-us")
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Accept", "*/*")
        $headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.42")
        if ($line.service -eq "Azure_Storage"){
            $body = "{`"id`":`"/subscriptions/$subscription_id/resourceGroups/"+ $line.res_group +"/providers/Microsoft.Storage/storageAccounts/"+$line.name+"/providers/microsoft.insights/diagnosticSettings/Terera`",`"name`":`"Terera`",`"properties`":{`"logs`":[],`"metrics`":[{`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false},`"category`":`"Transaction`"}],`"workspaceId`":`"$workspace_id`",`"logAnalyticsDestinationType`":null}}"
            $url = 'https://management.azure.com/subscriptions/'+ $subscription_id+'/resourceGroups/'+ $line.res_group +'/providers/Microsoft.Storage/storageAccounts/'+ $line.name +'/providers/microsoft.insights/diagnosticSettings/Terera?api-version=2021-05-01-preview'
            $response = Invoke-RestMethod $url -Method 'PUT' -Headers $headers -Body $body
            $response | ConvertTo-Json
            Write-Output $response
            $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $headers.Add("x-ms-command-name", "Microsoft_Azure_Monitoring.")
            $headers.Add("Accept-Language", "en")
            $headers.Add("Authorization", "Bearer $token")
            $headers.Add("x-ms-effective-locale", "en.en-us")
            $headers.Add("Content-Type", "application/json")
            $headers.Add("Accept", "*/*")
            $headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.42")
            $body = "{`"id`":`"/subscriptions/"+$subscription_id+"/resourceGroups/"+$line.res_group+"/providers/Microsoft.Storage/storageAccounts/"+$line.name+"/fileServices/default/providers/microsoft.insights/diagnosticSettings/teasaetasdasd`",`"name`":`"teasaet`",`"properties`":{`"logs`":[{`"category`":`"StorageRead`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"StorageWrite`",`"categoryGroup`":null,`"enabled`":false,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"StorageDelete`",`"categoryGroup`":null,`"enabled`":false,`"retentionPolicy`":{`"days`":0,`"enabled`":false}}],`"metrics`":[{`"enabled`":false,`"retentionPolicy`":{`"days`":0,`"enabled`":false},`"category`":`"Transaction`"}],`"workspaceId`":`"$workspace_id`",`"logAnalyticsDestinationType`":null}}"
            $response = Invoke-RestMethod $url -Method 'PUT' -Headers $headers -Body $body
            $response | ConvertTo-Json
            $url = 'https://management.azure.com/subscriptions/'+ $subscription_id +'/resourceGroups/'+$line.res_group+'/providers/Microsoft.Storage/storageAccounts/'+$line.name + '/blobServices/default/providers/microsoft.insights/diagnosticSettings/testa?api-version=2021-05-01-preview'
            $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $headers.Add("x-ms-command-name", "Microsoft_Azure_Monitoring.")
            $headers.Add("Accept-Language", "en")
            $headers.Add("Authorization", "Bearer $token")
            $headers.Add("x-ms-effective-locale", "en.en-us")
            $headers.Add("Content-Type", "application/json")
            $headers.Add("Accept", "*/*")
            $headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.42")
            $headers.Add("Referer", "")
            $body = "{`"id`":`"/subscriptions/"+$subscription_id+"/resourceGroups/"+$line.res_group+"/providers/Microsoft.Storage/storageAccounts/"+$line.name+"/blobServices/default/providers/microsoft.insights/diagnosticSettings/testa`",`"name`":`"testa`",`"properties`":{`"logs`":[{`"category`":`"StorageRead`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"StorageWrite`",`"categoryGroup`":null,`"enabled`":false,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"StorageDelete`",`"categoryGroup`":null,`"enabled`":false,`"retentionPolicy`":{`"days`":0,`"enabled`":false}}],`"metrics`":[{`"enabled`":false,`"retentionPolicy`":{`"days`":0,`"enabled`":false},`"category`":`"Transaction`"}],`"workspaceId`":`"$workspace_id`",`"logAnalyticsDestinationType`":null}}"
            $response = Invoke-RestMethod $url -Method 'PUT' -Headers $headers -Body $body
            $response | ConvertTo-Json
            
        }
        elseif($line.service -eq "Azure_KeyVault"){
            $body = "{`"id`":`"/subscriptions/$subscription_id/resourceGroups/" + $line.res_group + "/providers/Microsoft.KeyVault/vaults/"+$line.name+"/providers/microsoft.insights/diagnosticSettings/teasd`",`"name`":`"teasd`",`"properties`":{`"logs`":[{`"category`":null,`"categoryGroup`":`"audit`",`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":null,`"categoryGroup`":`"allLogs`",`"enabled`":false,`"retentionPolicy`":{`"days`":0,`"enabled`":false}}],`"metrics`":[{`"enabled`":false,`"retentionPolicy`":{`"days`":0,`"enabled`":false},`"category`":`"AllMetrics`"}],`"workspaceId`":`"$workspace_id`",`"logAnalyticsDestinationType`":null}}"
            $url = 'https://management.azure.com/subscriptions/'+$subscription_id+'/resourceGroups/'+ $line.res_group +'/providers/Microsoft.KeyVault/vaults/'+ $line.name +'/providers/microsoft.insights/diagnosticSettings/teasd?api-version=2021-05-01-preview'
            $response = Invoke-RestMethod $url -Method 'PUT' -Headers $headers -Body $body
            $response | ConvertTo-Json
            Write-Output $response
        }
        
    }
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("x-ms-command-name", "Microsoft_Azure_Monitoring.")
    $headers.Add("Accept-Language", "en")
    $headers.Add("Authorization", "Bearer $token")
    $headers.Add("x-ms-effective-locale", "en.en-us")
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Accept", "*/*")
    $headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.42")
    $headers.Add("Referer", "")
    $body = "{`"id`":`"/providers/microsoft.aadiam/providers/microsoft.insights/diagnosticSettings/treasdasdasd`",`"name`":`"treasdasdasd`",`"properties`":{`"logs`":[{`"category`":`"AuditLogs`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"SignInLogs`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"NonInteractiveUserSignInLogs`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"ServicePrincipalSignInLogs`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"ManagedIdentitySignInLogs`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"ProvisioningLogs`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"ADFSSignInLogs`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"RiskyUsers`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"UserRiskEvents`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"NetworkAccessTrafficLogs`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"RiskyServicePrincipals`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"ServicePrincipalRiskEvents`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"EnrichedOffice365AuditLogs`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}},{`"category`":`"MicrosoftGraphActivityLogs`",`"categoryGroup`":null,`"enabled`":true,`"retentionPolicy`":{`"days`":0,`"enabled`":false}}],`"metrics`":[],`"workspaceId`":`"$workspace_id`",`"logAnalyticsDestinationType`":null}}"
    $response = Invoke-RestMethod 'https://management.azure.com/providers/microsoft.aadiam/diagnosticSettings/treasdasdasd?api-version=2017-04-01-preview' -Method 'PUT' -Headers $headers -Body $body
    $response | ConvertTo-Json
    Write-Output $workspace_id

#     foreach ($rule in $rules){
#         $subscriptionId=(Get-AzContext).Subscription.Id
#         $dimension = New-AzScheduledQueryRuleDimensionObject -Name Computer -Operator Include -Value *
#         $condition=New-AzScheduledQueryRuleConditionObject -Dimension $dimension -Query  -TimeAggregation "Average" -MetricMeasureColumn "AggregatedValue" -Operator "GreaterThan" -Threshold "70" -FailingPeriodNumberOfEvaluationPeriod 1 -FailingPeriodMinFailingPeriodsToAlert 1
#         New-AzScheduledQueryRule -Name test-rule -ResourceGroupName test-group -Location eastus -DisplayName test-rule -Scope "/subscriptions/$SubscriptionId/resourceGroups/test-group/providers/Microsoft.Compute/virtualMachines/test-vm" -Severity 4 -WindowSize ([System.TimeSpan]::New(0,10,0)) -EvaluationFrequency ([System.TimeSpan]::New(0,5,0)) -CriterionAllOf $condition
# }

}