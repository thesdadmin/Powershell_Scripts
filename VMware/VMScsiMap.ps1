##Get VMware VM SCSI controller and Virtual Harddisk mapping.
##Based on code from https://code.vmware.com/forums/2530/vsphere-powercli#578118
function Get-VMSCSIMap {
    param(
    [parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
    [String[]]
  [array]
  $VM
    )
  $vmtarget=$VM
  $VM_harddisk=Get-Harddisk -VM $vmtarget
  $VM_harddisk | Select-Object @{N='VM';E={$_.Parent.Name}},Name,CapacityGB,@{N='SCSIid';E={
        $hd = $_
        $ctrl = $hd.Parent.Extensiondata.Config.Hardware.Device | where-object {$_.Key -eq $hd.ExtensionData.ControllerKey}
        "$($ctrl.BusNumber):$($_.ExtensionData.UnitNumber)"
     }}}
