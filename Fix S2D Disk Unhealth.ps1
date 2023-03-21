################################################################
#                                                              #
#              Fix S2D Disk unhealth                           #
#                By Cary Sun - MVP                             #
#                                                              #
################################################################


$disks=Get-PhysicalDisk | where {$_.operationalstatus -eq 'Transient Error'}

#Set disks to retired state
$disks |  Select-Object UniqueId | ForEach-Object {
    Set-PhysicalDisk -UniqueId $PSItem.UniqueId -Usage Retired
}

#remove disks from pool
$disks | ForEach-Object {
    Remove-PhysicalDisk -PhysicalDisks $PSItem -StoragePoolFriendlyName 'VeeamSP01' -Confirm:$false
}

#reset a disk from pool
$PDToAdd = Get-PhysicalDisk -SerialNumber S4NDNA0N900271
Add-PhysicalDisk -PhysicalDisks $PDToAdd -StoragePoolFriendlyName 'VeeamSP01'

#add a disk to the pool
$PDToAdd = Get-PhysicalDisk -SerialNumber S4NDNA0N900271
Add-PhysicalDisk -PhysicalDisks $PDToAdd -StoragePoolFriendlyName 'VeeamSP01'

#reset disks from pool
$disks | ForEach-Object {
    Reset-PhysicalDisk -PhysicalDisks $PSItem -StoragePoolFriendlyName 'VeeamSP01' -Confirm:$false
}

Get-PhysicalDisk -CanPool $true | ForEach-Object{
    Add-PhysicalDisk -StoragePool 'VeeamSP01' -PhysicalDisks $PSItem
}



#add all nvme drives to the pool (wasn't added before)
Add-PhysicalDisk -PhysicalDisks (Get-PhysicalDisk -CanPool $True) -StoragePoolFriendlyName 'VeeamSP01'
#set nvme as journal
Set-PhysicalDisk -FriendlyName 'NVMe INTEL SSDPECME02' -Usage Journal

#verify
Get-PhysicalDisk -FriendlyName 'NVMe INTEL SSDPECME02'

Update-StorageProviderCache -DiscoveryLevel Full