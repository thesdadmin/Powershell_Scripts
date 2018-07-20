$servers="SV1","SV2","SV3"
Invoke-Command -ComputerName $servers -ScriptBlock {
Restart-Computer -Force -Verbose
##Set Timezone
Set-TimeZone -Name "Pacifice Standard Time" 
##Install IIS
Add-WindowsFeature Web-Server -Includeallsubfeature -verbose
## Enable .NET 3.5 
Add-WindowsFeature Net-Framework-Features -includeallsubfeature -verbose 
## enable RDP
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 0
Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 1
Enable-NetFirewallRule -DisplayGroup “Remote Desktop”
}
