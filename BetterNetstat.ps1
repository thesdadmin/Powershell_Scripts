##source https://mikefrobbins.com/2018/07/19/use-powershell-to-determine-what-your-system-is-talking-to/
## doesn't work on systems earlier than Server 2016/Win10
Get-NetTCPConnection -State Established |
Select-Object -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, State,
                        @{name='Process';expression={(Get-Process -Id $_.OwningProcess).Name}}, CreationTime |
Format-Table -AutoSize
