##Get VMware VM SCSI controller and Virtual Harddisk mapping. 
Function Get-VMSCSIMap {

Select @{N='VM';E={$_.Parent.Name}},Name,CapacityGB,
    @{N='SCSIid';E={
        $hd = $_
        $ctrl = $hd.Parent.Extensiondata.Config.Hardware.Device | where{$_.Key -eq $hd.ExtensionData.ControllerKey}
        "$($ctrl.BusNumber):$($_.ExtensionData.UnitNumber)"
     }}
