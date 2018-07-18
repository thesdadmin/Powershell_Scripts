Function Get-WinFirewallLog {
[cmdletbinding()]
Param (
[Parameter(
    Mandatory=$true,
    ValueFromPipelineByPropertyName=$true,
    Position=0)]

[String[]]
$NetFirewallProfile 
)

#End parameters 

FWprofile=Get-netfirewallprofile $NetFirewallProfile
$LogEnabled=$FWprofile.Enabled
$LogAllowed=$FWprofile.LogAllowed
$LogBlocked=$FWprofile.LogBlocked
$Filename = [System.Environment]::ExpandEnvironmentVariables("$FWprofile.Logfilename")
$WinFWLog=[ordered]@{}
$LogOutput =  ForEach ($Line in gc $Filename | where {$_ -notmatch ‘^\s*$|^#’})
{
    $Data = $line.split(" ")
    $Date = $Data[0]
    $Time = $Data[1]
    $Action = $Data[2]
    $Protocol = $Data[3]
    $Srcip = $Data[4]
    $Dstip = $Data[5]
    $Srcprt = $Data[6]
    $Dstprt = $Data[7]
    $Path = $Data[16]
    $LogObj = New-Object PSObject
    Add-Member -InputObject $LogObj -MemberType NoteProperty -name “Action” -value $Action
    Add-Member -InputObject $LogObj -MemberType NoteProperty -name “Date” -value $Date
    Add-Member -InputObject $LogObj -MemberType NoteProperty -name “Time” -value $Time
    Add-Member -InputObject $LogObj -MemberType NoteProperty -name “Source IP” -value $Srcip
    Add-Member -InputObject $LogObj -MemberType NoteProperty -name “Destination Ip” -value $Dstip
    Add-Member -InputObject $LogObj -MemberType NoteProperty -name “Source Port” -value $Srcprt
    Add-Member -InputObject $LogObj -MemberType NoteProperty -name “Destination Port” -value $Dstprt
    Add-Member -InputObject $LogObj -MemberType NoteProperty -name “Protocol” -value $Protocol
    Add-Member -InputObject $LogObj -MemberType NoteProperty -name “Direction” -value $Path
    $LogObj 



}
$logOutput | ft -AutoSize -Wrap
}

