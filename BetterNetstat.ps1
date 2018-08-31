Get-NetTCPConnection -State Established |
Select-Object -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, State,
                        @{name='Process';expression={(Get-Process -Id $_.OwningProcess).Name}}, CreationTime |
Format-Table -AutoSize
