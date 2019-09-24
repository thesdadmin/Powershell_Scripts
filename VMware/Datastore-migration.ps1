$vcenter='somevcenter'
$creds=Get-credential -inline
Connect-viserver -server $vcenter -credential $creds

$oldclus=Get-Datastorecluster ScaleIO
$newclus=Get-Datastorecluster WinSS-Cluster

#$targetvms = Get-vm -Datastore $oldclus |where-object {$_.PowerState -eq 'PoweredOn'}
Do{Get-VM -Datastore $oldclus| select-object -First 3 | move-vm -Datastore $newclus -RunAsync
    start-sleep -Seconds 1200}until((Get-VM -Datastore $oldclus) -eq 2)
else {
    Write-infomation "No VMs to move"
}