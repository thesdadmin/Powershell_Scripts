Function Connect-Exchange {
 
    param(
        [Parameter( Mandatory=$false)]
        [string]$URL="mailserv3.mmclinic.com"
    )
    
    $Credentials = Get-Credential -Message "Enter your Exchange admin credentials"
 
    $ExOPSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$URL/PowerShell/ -Authentication Kerberos -Credential $Credentials
 
    Import-PSSession $ExOPSession
 
}