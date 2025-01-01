# Variables
$RG = 'hallinc-aks-stage-rg'
$VNET = 'vnet-test-stage-hallinc'
$AKS_SNET = 'snet-aks-test-stage-hallinc'
$ACR_HOST = 'acrteststagehallinc.azurecr.io'

function Wait-ForVMReady {
    param (
        [string]$ResourceGroup,
        [string]$VMName
    )

    $vm_ready = $false
    while (-not $vm_ready) {
        $vm_state = (az vm get-instance-view `
            --resource-group $RG `
            --name $VMName `
            --query "instanceView.statuses[?code=='PowerState/running'] | [0].displayStatus" `
            -o tsv)

        if ($vm_state -eq "VM running") {
            $vm_ready = $true
            Write-Output "$VMName is ready!"
        } 
        else {
            Write-Output "Waiting for $VMName to be ready..."
            Start-Sleep -Seconds 10
        }
    }
}

# Check if vm-aks exists, if not create it
$vm_aks = (az vm show --resource-group $RG --name vm-aks --query "name" -o tsv 2>$null)
if (-not $vm_aks) {
    $vm_aks = (az vm create `
    --resource-group $RG `
    --name vm-aks `
    --vnet-name $VNET `
    --subnet $AKS_SNET `
    --image Ubuntu2204 `
    --admin-username azureuser `
    --generate-ssh-keys `
    --query "name" -o tsv)
}

# Wait for vm-aks to be ready
Wait-ForVMReady -ResourceGroup $RG -VMName 'vm-aks'

# run test to ping ACR host endpoint from vm_aks
Write-Output "Running ping test to ACR host endpoint from AKS subnet"
$test = (az vm run-command invoke `
--resource-group $RG `
--name vm-aks `
--command-id RunShellScript `
--scripts "ping -c 4 $ACR_HOST" `
-o json | ConvertFrom-Json
)

# Extract the message field
$message = $test.value[0].message

# Check if 4 packets were received
if ($message -match "(\d+)% packet loss") {
    $packetLoss = [int]$matches[1]

    if ($packetLoss -eq 0) {
        Write-Output "Ping test succeeded: 0% packet loss."
    } else {
        Write-Error "Ping test failed: $packetLoss% packet loss."
    }
} else {
    Write-Error "Ping test failed: Unable to parse ping statistics."
}

# Cleanup
Write-Output "Cleaning up test resources.."
if ($vm_aks) {

    # Delete the VM
    az vm delete --resource-group $RG --name vm-aks --yes
    
    # Delete the network security group associated with the VM
    $vm_nsg = (az network nsg list --resource-group $RG --query "[?contains(name, 'vm-aks')].name" -o tsv)
    if ($vm_nsg) {
        az network nsg delete --resource-group $RG --name $vm_nsg
    }
    # Delete the public IP address associated with the VM
    $vm_public_ip = (az network public-ip list --resource-group $RG --query "[?contains(name, 'vm-aks')].name" -o tsv)
    if ($vm_public_ip) {
        az network public-ip delete --resource-group $RG --name $vm_public_ip
    }
    # Delete the network interface associated with the VM
    $vm_nic = (az network nic list --resource-group $RG --query "[?contains(name, 'vm-aks')].name" -o tsv)
    if ($vm_nic) {
        az network nic delete --resource-group $RG --name $vm_nic
    }
    # Delete the OS disk associated with the VM
    $vm_disk = (az disk list --resource-group $RG --query "[?contains(name, 'vm-aks')].name" -o tsv)
    if ($vm_disk) {
        az disk delete --resource-group $RG --name $vm_disk --yes
    }
}
Write-Output "Cleanup done."