$dsc_targets= 'server1','server2'
Invoke-Command -ComputerName $dsc_targets -ScriptBlock {
    $file1='C:\windows\system32\configuration\Current.mof'
    $file2='C:\Windows\system32\configuration\Current.mof.checksum'
    $file3='C:\Windows\system32\configuration\DSCEngineCache.mof'
    $file4='C:\Windows\system32\configuration\DSCResourceStateCache.mof'
    $file5='C:\Windows\System32\configuration\MetaConfig.mof'
    $file6='C:\Windows\System32\Configuration\MetaConfig.backup.mof'    
    Stop-DscConfiguration -Force -Confirm:$false
    Start-Sleep -Seconds 30
    Invoke-CimMethod -ClassName MSFT_DSCLocalConfigurationManager -MethodName "stopConfiguration" -Arguments @{Force=[System.Boolean]1} -Namespace "root\Microsoft\WIndows\DesiredStateConfiguration"
    Remove-DscConfigurationDocument -Stage Previous, Current, Pending -verbose
    Remove-item $file1,$file2,$file3,$file4,$file5,$file6 -ErrorAction SilentlyContinue
    Get-DscConfigurationStatus -Verbose
}
