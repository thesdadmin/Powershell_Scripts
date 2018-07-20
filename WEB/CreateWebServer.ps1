$servers="SV1","SV2"
Invoke-Command -ComputerName $servers -ScriptBlock {

##Set Timezone
Set-TimeZone -Name "Pacific Standard Time" 
##Install IIS
Add-WindowsFeature Web-Server -includeallsubfeature -verbose

## Enable .NET 3.5. If ou need to
#Add-WindowsFeature Net-Framework-Features -includeallsubfeature -verbose

##Optional, Install IIS Management service for Remote Management
#Add-WindowsFeature Web-Mgmt-Service -includeallsubfeature

##Optional, Enable remote mangement of IIS
#Set-ItemProperty 'HKLM:\Software\Microsoft\WebManagement\Server\' -Name "EnableRemoteManagement" -Value 1
#invoke-expression -Command "sc.exe config wmsvc start=delayed-auto"
#Start-service WMSVC
##Optional, enable RDP
#Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\‘ -Name “fDenyTSConnections” -Value 0
#Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 1
#Enable-NetFirewallRule -DisplayGroup “Remote Desktop”

##Configured Firewall logging, you can create separate logs per network profile. 
#$profile=Get-netadapter|get-netconnectionprofile
Set-NetFirewallProfile Domain -LogMaxSizeKiloBytes 32761 -LogAllowed True -LogBlocked True -LogIgnored True -logfilename C:\windows\system32\logfiles\Firewall\domain.log
}

