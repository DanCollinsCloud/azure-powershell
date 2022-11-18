$subscriptionName = (Get-AzContext).Subscription.Name

$vms = Get-AzVM
$vaults = Get-AzRecoveryServicesVault
foreach ($vm in $vms) {
    $protected = $null
    Write-Host "Checking VM " $vm.Name
    foreach ($Vault in $Vaults) {
        #write-host "Protected Status " $protected -ForegroundColor Yellow
        #Write-Host "Checking vault " $vault.Name
        Set-AzRecoveryServicesAsrVaultContext -Vault $Vault -InformationAction SilentlyContinue
        $Fabrics = Get-AzRecoveryServicesAsrFabric -InformationAction SilentlyContinue
        foreach ($Fabric in $Fabrics) {
            #Write-Output "Checking fabric " $fabric.FriendlyName
            $drContainers = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $Fabric
            foreach ($drContainer in $drContainers) {
                #Write-Output "Checking container " $drContainer.FriendlyName
                $protectedItem = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $drContainer -FriendlyName $vm.Name -ErrorAction SilentlyContinue
                if ($null -ne $protectedItem) {
                    Write-Host "VM IS PROTECTED" -ForegroundColor Green
                    $protected = $true
                    break
                }
            }
            if ($protected -eq $true) {
                #write-host "I have hit break 1 " $protected
                break
            }
        }
        if ($protected -eq $true) {
            #write-host "I have hit break 2 " $protected
            break
        }
    }
    if ($protected -ne $true) {
        Write-Host "VM IS NOT PROTECTED" -ForegroundColor Red
        $protected = $false
    }
    $output = [PSCustomObject]@{
        Subscription = $subscriptionName
        VMName        = $vm.Name
        Vault         = $Vault.Name
        VaultLocation = $Vault.Location
        Protected     = $protected
    } | Export-Csv C:\temp\export.csv -Append
}