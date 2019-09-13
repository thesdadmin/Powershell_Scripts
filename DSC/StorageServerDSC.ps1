

configuration StorageServer {
    param 
    (
    [string[]] $Computername = "localhost"
    )
        
    Import-DscResource -ModuleName PSDesiredStateConfiguration, iSCSIDSC, NetworkingDSC, ComputerManagementDSC
        Node $Computername 
        {
          
            Script StoragePool 
                {
                SetScript = {
                $disks=Get-PhysicalDisk -canpool $true    
                New-StoragePool -FriendlyName StoragePool1 -StorageSubSystemFriendlyName '*storage*' -PhysicalDisks $disks -ResiliencySettingNameDefault Mirror -LogicalSectorSizeDefault 512
                }
                TestScript = {
                (Get-StoragePool -ErrorAction SilentlyContinue -FriendlyName StoragePool1).OperationalStatus -eq 'OK'
                }
                GetScript = {
                @{Ensure = if ((Get-StoragePool -FriendlyName StoragePool1).OperationalStatus -eq 'OK') {'Present'} Else {'Absent'}}
                }
                }
            
            

            Script VirtualDisk
                {
                SetScript = {
                $disks = Get-StoragePool –FriendlyName StoragePool1 -IsPrimordial $False | Get-PhysicalDisk
                $diskNum = $disks.Count
                New-VirtualDisk –StoragePoolFriendlyName StoragePool1 –FriendlyName VirtualDisk1 –ResiliencySettingName simple -NumberOfColumns $diskNum –UseMaximumSize 
                    }
                TestScript = {
                (get-virtualdisk -ErrorAction SilentlyContinue -friendlyName VirtualDisk1).operationalSatus -EQ 'OK'
                    }
                GetScript = {
                @{Ensure = if ((Get-VirtualDisk -FriendlyName VirtualDisk1).OperationalStatus -eq 'OK') {'Present'} Else {'Absent'}}
                    }
                DependsOn = "[Script]StoragePool"
                }
            
            Script FormatDisk 
                {
                SetScript = {
                Get-VirtualDisk –FriendlyName VirtualDisk1 | Get-Disk | Initialize-Disk –Passthru | New-Partition –AssignDriveLetter –UseMaximumSize | Format-Volume -NewFileSystemLabel VirtualDisk1 –AllocationUnitSize 64KB -FileSystem NTFS
                }
                TestScript = {
                (get-volume -ErrorAction SilentlyContinue -filesystemlabel VirtualDisk1).filesystem -EQ 'NTFS'
                }
                GetScript = {
                @{Ensure = if ((get-volume -filesystemlabel VirtualDisk1).filesystem -EQ 'NTFS') {'Present'} Else {'Absent'}}
                }
                DependsOn = "[Script]VirtualDisk"
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
                Dhcp           = 'Disabled'
                }
        
            NetIPInterface DisableDHCP_3
                {
                    InterfaceAlias = 'NIC3'
                    AddressFamily  = 'IPv4'
                    Dhcp           = 'Disabled'
                }
            NetIPInterface DisableDHCP_4
                {
                    InterfaceAlias = 'NIC4'
                    AddressFamily  = 'IPv4'
                    Dhcp           = 'Disabled'
                }
            
            IPAddress StaticIP_1
                { 
                    InterfaceAlias = 'NIC1'
                    AddressFamily  = 'IPv4'
                    IPAddress      = '10.7.99.114/24'
                }
            
            IPAddress StaticIP_2
                {
                    InterfaceAlias  = 'NIC2'
                    AddressFamily   = 'IPv4'
                    IPAddress       = '10.7.99.115/24'                        
                }
            
            IPAddress StaticIP_3 
                {
                    InterfaceAlias = 'NIC3'
                    AddressFamily  = 'IPv4'
                    IPAddress      = '10.7.100.218/24'
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

            WindowsFeature iSCSITargetServerInstall
                {
                    Ensure = "Present"
                    Name   = "FS-iSCSITarget-Server"
                    
                }
                
        
            File ISCSIDisk
                {
                    Type = 'Directory'
                    DestinationPath = 'E:\iSCSIVirtualDisks'
                    Ensure = "Present"
                    
                }   
                    
                Service ISCSITarget
                {
                    Name   = 'WinTarget'
                    State  = 'Running'
                    Ensure = 'Present'
                    DependsOn = "[WindowsFeature]iSCSITargetServerInstall"

                }

            iSCSIVirtualDisk iSCSIClusterVDisk03
                    {
                        Ensure      = 'Present'
                        Path        = 'E:\iSCSIVirtualDisks\Datastore.vhdx'
                        DiskType    = 'Fixed'
                        SizeBytes   = 5TB
                        Description = 'Datastore Virtual Disk'                
                    }
            
            iSCSIServerTarget iSCSITarget
            {
                Ensure 	= 'Present'
                TargetName 	= 'ESXtarget'
                Paths	= 'E:\iSCSIVirtualDisks\Datastore.vhdx'
                InitiatorIds = 'iqn:iqn.1998-01.com.vmware:server2-1234','iqn:iqn.1998-01.com.vmware:server1-1234' #syntax is DNSName, IPAddress, IPv6Address, IQN, or MACAddress. see https://docs.microsoft.com/en-us/powershell/module/iscsitarget/new-iscsiservertarget?view=win10-ps
                Dependson 	= "[iSCSIVirtualDisk]iSCSIClusterVDisk"	
                    
            }
    
            Computer NewName
                {
                Name = 'WinSS'
                WorkGroupName = 'Storage'
                
                }
            
            TimeZone NewTimezone
                {
                IsSingleInstance = 'Yes'
                TimeZone = 'Coordinated Universal Time'
                }      
      
      
      
    }


}

StorageServer



