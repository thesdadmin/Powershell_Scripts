$VM = get-vm "TESTTWDB" 
$VMSummaries = @()
$DiskMatches = @()
$VMView = $VM | Get-View
    ForEach ($VirtualSCSIController in ($VMView.Config.Hardware.Device | Where {$_.DeviceInfo.Label -match "SCSI Controller"}))
        {
        ForEach ($VirtualDiskDevice  in ($VMView.Config.Hardware.Device | Where {$_.ControllerKey -eq $VirtualSCSIController.Key}))
            {
            $VMSummary = "" | Select VM, HostName, PowerState, DiskFile, DiskName, DiskSize, SCSIController, SCSITarget
            $VMSummary.VM = $VM.Name
            $VMSummary.HostName = $VMView.Guest.HostName
            $VMSummary.PowerState = $VM.PowerState
            $VMSummary.DiskFile = $VirtualDiskDevice.Backing.FileName
            $VMSummary.DiskName = $VirtualDiskDevice.DeviceInfo.Label
            $VMSummary.DiskSize = $VirtualDiskDevice.CapacityInKB * 1KB
            $VMSummary.SCSIController = $VirtualSCSIController.BusNumber
            $VMSummary.SCSITarget = $VirtualDiskDevice.UnitNumber
            $VMSummaries += $VMSummary
            }
        }
$Disks = Get-WmiObject -Class Win32_DiskDrive -ComputerName $VM.Name
$Diff = $Disks.SCSIPort | sort-object -Descending | Select -last 1 
foreach ($device in $VMSummaries)
   {
    $Disks | % {if((($_.SCSIPort - $Diff) -eq $device.SCSIController) -and ($_.SCSITargetID -eq $device.SCSITarget))
           {
             $DiskMatch = "" | Select VMWareDisk, VMWareDiskSize, WindowsDeviceID, WindowsDiskSize 
             $DiskMatch.VMWareDisk = $device.DiskName
             $DiskMatch.WindowsDeviceID = $_.DeviceID.Substring(4)
             $DiskMatch.VMWareDiskSize = $device.DiskSize/1gb
             $DiskMatch.WindowsDiskSize =  [decimal]::round($_.Size/1gb)
             $DiskMatches+=$DiskMatch
            }
        }
   }
$DiskMatches 
