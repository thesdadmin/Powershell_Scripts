### If you administer Exchange on-premise, this is a handy function to have in your user profile or saved in a local path.

Function Connect-Exchange {
 
    param(
        [Parameter( Mandatory=$false)]
        [string]$URL="mailserv3.mmclinic.com"
    )
    
    $Credentials = Get-Credential -Message "Enter your Exchange admin credentials"
 
    $ExOPSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$URL/PowerShell/ -Authentication Kerberos -Credential $Credentials
 
    Import-PSSession $ExOPSession
 
}
