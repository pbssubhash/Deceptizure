Connect-AzureAD
$headerss = @("UserPrincipalName","DisplayName","UserName","Password")  
$csv = Import-Csv "CreateUsers.csv" -Header $headerss | Select-Object -skip 1
foreach($line in $csv) {
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $line.Password
    New-AzureADUser -AccountEnabled $True -DisplayName $line.DisplayName -PasswordProfile $PasswordProfile -MailNickName $line.MailNickName -UserPrincipalName $line.UserPrincipalName
}
$headerss = @("Name","ResourceGroupName","Location") 
$csv = Import-Csv "MSI.csv" -Header $headerss | Select-Object -skip 1
foreach($line in $csv) {
     New-AzUserAssignedIdentity -ResourceGroupName $line.ResourceGroupName -Name $line.Name -Location $line.Location
}
$myJson = Get-Content .\test.json -Raw | ConvertFrom-Json 

foreach($line in $csv) {
    $myJson = Get-Content .\test.json -Raw | ConvertFrom-Json 

}
