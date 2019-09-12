configuration StorageServer_1 {
##Specify node
    Import-DscResource -ModuleName PSDesiredStateConfiguration, iSCSIDSC, NetworkingDSC
    Node Localhost 
    {
        Script StoragePool {
            SetScript = {
            $disks=Get-StoragePool -IsPrimordial $true | Get-PhysicalDisk | Where-Object CanPool -eq $True
            New-StoragePool –FriendlyName StoragePool1 –StorageSubsystemFriendlyName “Storage Spaces*” –PhysicalDisks $disks    
            #New-StoragePool -FriendlyName StoragePool1 -StorageSubSystemFriendlyName '*storage*' -PhysicalDisks $disks
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
        
        NetIPInterface DisableDHCP
        {
            InterfaceAlias = 'NIC1'
            AddressFamily  = 'IPv4'
            Dhcp           = 'Disabled'
        }
    
    NetIPInterface DisableDHCP_2
        {
            InterfaceAlias = 'NIC2'
            AddressFamily  = 'IPv4'
            Dhcp           = 'Disable'
        }
    
    NetIPInterface DisableDHCP_3
        {
            InterfaceAlias = 'NIC3'
            AddressFamily  = 'IPv4'
            Dhcp           = 'Disable'
        }
    NetIPInterface DisableDHCP_4
        {
            InterfaceAlias = 'NIC4'
            AddressFamily  = 'IPv4'
            Dhcp           = 'Disable'
        }
    
    IPAddress StaticIP_1
        { 
            InterfaceAlias = 'NIC1'
            AddressFamily  = 'IPv4'
            IPAddress      = '10.7.99.110/24'
        }
    
    IPAddress StaticIP_2
        {
            InterfaceAlias  = 'NIC2'
            AddressFamily   = 'IPv4'
            IPAddress       = '10.7.99.111/24'                        
        }
    
    IPAddress StaticIP_3 
        {
            InterfaceAlias = 'NIC3'
            AddressFamily  = 'IPv4'
            IPAddress      = '10.7.100.217/24'
        }
    DefaultGatewayAddress DefaultGW
        {
            InterfaceAlias = 'NIC3'
            AddressFamily  = 'IPv4'
            Address        = '10.7.100.1'
        }    
    DnsServerAddress DnsServers
        {
            Address         = '10.7.100.178','10.7.100.179'
            InterfaceAlias  = 'NIC3'
            AddressFamily   = 'IPv4'
            Validate        = $true
        }    
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
                Path        = 'E:\iSCSIVirtualDisks\Datastore_1.vhdx'
                DiskType    = 'Fixed'
                SizeBytes   = 4.9TB
                Description = 'Datastore Virtual Disk'
                DependsOn   = "[Service]ISCSITarget"
            } # End of iSCSIVirtualDisk Resource
        
    

}





