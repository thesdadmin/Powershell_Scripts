configuration StorageServer {
##Specify node
    Import-DscResource -ModuleName PSDesiredStateConfiguration, iSCSIDSC
    Node Localhost 
    {
        Script StoragePool {
            SetScript = {
            $disks=Get-StoragePool -IsPrimordial $true | Get-PhysicalDisk | Where-Object CanPool -eq $True
            $pool=New-StoragePool –FriendlyName StoragePool1 –StorageSubsystemFriendlyName “Storage Spaces*” –PhysicalDisks $disks    
            New-StoragePool -FriendlyName StoragePool1 -StorageSubSystemFriendlyName '*storage*' -PhysicalDisks $disks
        }
        TestScript = {
            (Get-StoragePool -ErrorAction SilentlyContinue -FriendlyName StoragePool1).OperationalStatus -eq 'OK'
        }
        GetScript = {
            @{Ensure = if ((Get-StoragePool -FriendlyName StoragePool1).OperationalStatus -eq 'OK') {'Present'} Else {'Absent'}}
        }

        }
        Script StorageVolume {
            SetScript = {
             $storagedisk=Get-VirtualDisk –FriendlyName VirtualDisk1| Get-Disk 
             Initialize-Disk -Number $storagedisk.number –Passthru | New-Partition –AssignDriveLetter -DriveLetter E –UseMaximumSize 
             Format-Volume -DriveLetter E -NewFileSystemLabel "StorageDisk" -FileSystem NTFS
            }
            TestScript = {Get-virtualdisk -friendlyname VirtualDisk1 | Get-Disk|Get-partition|Get-Volume -driveLetter E }
            GetScript  = { @{Result =(Get-Volume -driveLetter E)}}

        }
        WindowsFeature iSCSITargetServerInstall
            {
                Ensure = "Present"
                Name   = "FS-iSCSITarget-Server"
            }
            
        Service ISCSITarget
            {
                Name   = 'WinTarget'
                State  = 'Running'
                Ensure = 'Present'
                DependsOn = "[WindowsFeature]ISCSITargetServerInstall"

            }
        File ISCSIDisk
            {
                Type = 'Directory'
                DestinationPath = 'E:\iSCSIVirtualDisks'
                Ensure = "Present"
            }   
                
        iSCSIVirtualDisk iSCSIClusterVDisk01
            {
                Ensure      = 'Present'
                Path        = 'E:\iSCSIVirtualDisks\Datastore.vhdx'
                DiskType    = 'Fixed'
                SizeBytes   = 5.9TB
                Description = 'Datastore Virtual Disk'
                DependsOn   = "[Service]ISCSITarget"
            } # End of iSCSIVirtualDisk Resource
    }
}



