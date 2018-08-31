Set-ItemProperty -Path “HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System” -Name “EnableLUA” -Value “0”
set-ItemProperty -Path 'HKLM:SystemCurrentControlSetControlTerminal Server'-name "fDenyTSConnections" -Value 0  
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"  
set-ItemProperty -Path 'HKLM:SystemCurrentControlSetControlTerminal ServerWinStationsRDP-Tcp' -name "UserAuthentication" -Value 1    

Get-Disk |
Where partitionstyle -eq 'raw' |
Initialize-Disk -PartitionStyle MBR -PassThru |
New-Partition -AssignDriveLetter -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "disk2" -Confirm:$false
