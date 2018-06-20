$DhcpServer = Get-DhcpServerInDC
$leases=@($DhcpServer).foreach({
@(Get-DhcpServerv4Scope -ComputerName $_.DnsName).foreach({
Get-DhcpServerv4Lease  –ScopeId $_.ScopeId
})
})