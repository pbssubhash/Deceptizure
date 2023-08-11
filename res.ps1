# RIf you are getting no res provider found, use Register-AzResourceProvider -ProviderNamespace "Microsoft.Storage"

[CmdletBinding()]
param (
    [Parameter(Position=0,mandatory=$true)]
    [string] $Mode,
    [Parameter(Position=0,mandatory=$true)]
    [string] $OutputFolder
)
$resources = Get-Content "$OutputFolder\resources.json"
$msi = Get-Content "$OutputFolder\msi.json"
$msi_attach = Get-Content "$OutputFolder\attach_msi.json"
$users = Get-Content "$OutputFolder\user.json"
$user_perm = Get-Content "$OutputFolder\user_perm.json"
$msi_perm = Get-Content "$OutputFolder\msi_perm.json"
$kv_perm = Get-Content "$OutputFolder\kv_perms.json"
$storage_perm = Get-Content "$OutputFolder\storage_perms.json"
if ($Mode -eq "Deploy") {
    foreach($user in $users){
        $user = ConvertFrom-Json $user
        $password = ConvertTo-SecureString -AsPlainText -Force $user.password
        $out = New-AzADUser -DisplayName $user.DisplayName -Password $password -MailNickName $user.UserName -UserPrincipalName $user.UserPrincipalName
        Write-Output $out
    }

    foreach($msix in $msi){
        $msix = ConvertFrom-Json $msix
        $out = New-AzUserAssignedIdentity -ResourceGroupName $msix.ResourceGroup -Name $msix.name -Location $msix.Location
        Write-Output $out
    }
    #["Azure_Function","Azure_Automation","Azure_Storage","Azure_Logic_App","Azure_KeyVault","Disk"]
    # Working
    foreach($resource in $resources){
        $resource = ConvertFrom-Json $resource
        if ($resource.service -eq "Azure_Logic_App") {
            $out =  New-AzLogicApp -ResourceGroupName $resource.res_group -Name $resource.name -Location $resource.location -State "Disabled" -DefinitionFilePath ./workflow_def.json
            Write-Output $out
        }
        elseif ($resource.service -eq "Azure_Automation") {
            $out =  New-AzAutomationAccount -Name $resource.name -Location $resource.location -ResourceGroupName $resource.res_group
            Write-Output $out
        }
        elseif ($resource.service -eq "Azure_Function") {
            New-AzStorageAccount -ResourceGroupName $resource.res_group -Name $resource.properties.StorageAccountName -Location $resource.location -SkuName Standard_LRS
            $out = New-AzFunctionApp -DisableApplicationInsights -Name $resource.name -ResourceGroupName $resource.res_group -Location $resource.location -StorageAccountName $resource.properties.StorageAccountName -Runtime Python
            Write-Output $out
        }
        elseif ($resource.service -eq "Azure_Storage") {
            $out =  New-AzStorageAccount -ResourceGroupName $resource.res_group -Name $resource.name -Location $resource.location -SkuName Standard_LRS
            Write-Output $out
        }
        elseif ($resource.service -eq "Disk") {
            $diskconfig = New-AzDiskConfig -Location $resource.properties.Location -DiskSizeGB $resource.properties.DiskSizeGB -SkuName $resource.properties.SkuName -OsType $resource.properties.OsType -CreateOption Empty
            $out = New-AzDisk -ResourceGroupName $resource.res_group -DiskName $resource.name -Disk $diskconfig
            Write-Output $out
        }
        elseif ($resource.service -eq "Azure_KeyVault") {
            $out = New-AzKeyVault -VaultName $resource.name -ResourceGroupName $resource.res_group -Location $resource.location
            Write-Output $out
        }
    }
    Write-Output "Resource Creation Complete"
    foreach($perm in $msi_perm) {
        $perm = ConvertFrom-Json $perm
        if ($perm.type -eq "Azure_Logic_App"){
            $scope = (Get-AzResource -ResourceType 'Microsoft.Logic/workflows' -Name $perm.resource).ResourceId
        } 
        elseif ($resource.type -eq "Azure_Functions"){
            $scope = (Get-AzResource -ResourceType 'Microsoft.Web/sites' -Name $perm.resource).ResourceId
        }elseif ($resource.type -eq "Azure_Automation"){
            $scope = (Get-AzResource -ResourceType 'Microsoft.Automation/automationAccounts' -Name $perm.resource).ResourceId
        }
        $obj = (Get-AzUserAssignedIdentity -ResourceGroup $perm.msi_rg -Name $perm.name).PrincipalId
        $out = New-AzRoleAssignment -RoleDefinitionName $perm.role -Scope $scope -ObjectId $obj
        Write-Output $out
    }

    foreach($perm in $user_perm) {
        $perm = ConvertFrom-Json $perm
        if ($perm.type -eq "Azure_Logic_App"){
            $scope = (Get-AzResource -ResourceType 'Microsoft.Logic/workflows' -Name $perm.resource).ResourceId
        } 
        elseif ($resource.type -eq "Azure_Functions"){
            $scope = (Get-AzResource -ResourceType 'Microsoft.Web/sites' -Name $perm.resource).ResourceId
        }elseif ($resource.type -eq "Azure_Automation"){
            $scope = (Get-AzResource -ResourceType 'Microsoft.Automation/automationAccounts' -Name $perm.resource).ResourceId
        }
        $obj = (Get-AzADUser -UserPrincipalName $perm.user).Id
        $out = New-AzRoleAssignment -RoleDefinitionName $perm.role -Scope $scope -ObjectId $obj
        Write-Output $out
    }
    foreach ($msiz in $msi_attach) {
        $msiz = ConvertFrom-Json $msiz
        $msi_id = (Get-AzUserAssignedIdentity -Name $msiz.name -ResourceGroupName $msiz.msi_rg).Id
        $token = (Get-AzAccessToken -ResourceUrl "https://management.azure.com") | Select-Object Token -ExpandProperty Token
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("x-ms-command-name", "Microsoft_Azure_ManagedServiceIdentity.")
        $headers.Add("Accept-Language", "en")
        $headers.Add("Authorization", "Bearer $token")
        $headers.Add("x-ms-effective-locale", "en.en-us")
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Accept", "*/*")
        $headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.42")
        $body = "{`"identity`":{`"type`":`"userassigned`",`"userAssignedIdentities`":{`"$msi_id`":{}}}}"
        if ($msiz.type -eq "Azure_Logic_App") {
            $url = "https://management.azure.com/subscriptions/" + $msiz.subscription_id + "/resourceGroups/" + $msiz.rg + "/providers/Microsoft.Logic/workflows/" + $msiz.resource + "?api-version=2016-10-01"
        }
        elseif ($msiz.type -eq "Azure_Automation") {
            $url = "https://management.azure.com/subscriptions/" + $msiz.subscription_id + "/resourceGroups/" + $msiz.rg + "/providers/Microsoft.Automation/automationAccounts/" + $msiz.resource + "?api-version=2020-01-13-preview"
        }
        elseif ($msiz.type -eq "Azure_Functions"){
            $url = "https://management.azure.com/subscriptions/" + $msiz.subscription_id + "/resourceGroups/" + $msiz.rg + "/providers/Microsoft.Web/sites/" + $msiz.resource + "?api-version=2018-11-01"
        }
            $response = Invoke-RestMethod $url -Method 'PATCH' -Headers $headers -Body $body
            $response | ConvertTo-Json
            Write-Output $response
    }
    foreach($kv in $kv_perm){
        $kv = ConvertFrom-Json $kv 
        if ($kv.type -eq "user"){
            Set-AzKeyVaultAccessPolicy -VaultName $kv.name -UserPrincipalName $kv.user -PermissionsToKeys create,import,delete,list -PermissionsToSecrets set,delete -PassThru
        }
        elseif ($kv.type -eq "msi"){
            $obj = (Get-AzUserAssignedIdentity -ResourceGroup $kv.rg -Name $kv.user).PrincipalId
            Set-AzKeyVaultAccessPolicy -VaultName $kv.name -ObjectId $obj -PermissionsToKeys create,import,delete,list -PermissionsToSecrets set,delete -PassThru

        }
    }
    foreach ($sp in $storage_perm){
        $sp = ConvertFrom-Json $sp
        if ($sp.type -eq "user"){
            $obj_id = (Get-AzADUser -UserPrincipalName $sp.user).Id
        }elseif ($sp.type -eq "msi"){
            $obj_id = (Get-AzUserAssignedIdentity -ResourceGroupName $sp.rg -Name $sp.user).PrincipalId
        }
        $scope = (Get-AzStorageAccount -Name $sp.name -ResourceGroupName $sp.sa_rg).Id
        #Write-Output $scope
        $out = New-AzRoleAssignment -RoleDefinitionName $sp.perm -ObjectId $obj_id -Scope $scope
        Write-Output $out
    }
}
elseif ($Mode -eq "Remove") {
    foreach ($res in $resources) {
      $res = ConvertFrom-Json $res 
      if ($res.service -eq "Azure_Logic_App"){
        $type = "Microsoft.Logic/workflows"
      }
      elseif ($res.service -eq "Azure_Function"){
        $type = "Microsoft.Web/sites"
      }
      elseif ($res.service -eq "Disk"){
        $type = "Microsoft.Compute/disks"
      }
      elseif ($res.service -eq "Azure_KeyVault"){
        $type = "Microsoft.KeyVault/vaults"
      }
      elseif ($res.service -eq "Azure_Storage"){
        $type = "Microsoft.Storage/storageAccounts"
      }
      elseif ($res.service -eq "Azure_Automation"){
        $type = "Microsoft.Automation/automationAccounts"
      }
      $id = (Get-AzResource -ResourceType $type -Name $res.name).ResourceId
      $out = Remove-AzResource -ResourceId $id -Force
      Write-Output $out
    }
    foreach ($user in $users){
        $user = ConvertFrom-Json $user
        Remove-AzADUser -UserPrincipalName $user.UserPrincipalName
    }
    foreach ($msix in $msi){
        $msix = ConvertFrom-Json $msix
        Remove-AzUserAssignedIdentity -Name $msix.name -ResourceGroupName $msix.ResourceGroup
    }
}