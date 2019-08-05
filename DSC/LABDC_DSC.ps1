
Configuration LABDC

$secpasswd = Read-host -AsSecureString -Prompt ("Enter Local Admin password")
$localuser = New-Object System.Management.Automation.PSCredential ($env:USERNAME, $secpasswd)
$DomainName=Read-Host -Prompt ("What is the domain name?")
$firstDomainAdmin =  (Get-Credential -UserName "$domainName\$env:USERNAME" -Message 'Store your credentials')
$SafeModePW=(Get-Credential -username guest -Message "DSRM Password")
$localuser = New-Object System.Management.Automation.PSCredential ('guest', $secpasswd)
$machinename = $env:COMPUTERNAME
Configuration LABDC
{ 
  param
    (
        [string[]]$NodeName ='localhost',
        [Parameter(Mandatory)][string]$machinename, $firstDomainAdmin,
        [Parameter(Mandatory)][string]$DomainName,
        [Parameter()][string]$UserName,
        [Parameter(Mandatory)]$SafeModePW,
        [Parameter()]$Password
    ) 
 
    Import-DscResource -ModuleName xActiveDirectory,PSDesiredStateConfiguration


    Node localhost
    {
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true            
        }
       
        File ADFiles
        {
            DestinationPath = 'D:\NTDS'
            Type = 'Directory'
            Ensure = 'Present'
        }

        WindowsFeature RSAT 
        {
            Ensure = "Present"
            Name = "RSAT-AD-Tools"
            IncludeAllSubFeature = $true
        }

        WindowsFeature DNSTools 
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
            IncludeAllSubFeature = $true
        }
        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
            IncludeAllSubFeature = $true
        }
 
        xADDomain SetupDomain {
                    DomainAdministratorCredential= $firstDomainAdmin
                    DomainName= $DomainName
                    SafemodeAdministratorPassword= $SafeModePW
                    DependsOn='[WindowsFeature]RSAT'
                    DomainNetbiosName = $DomainName.Split('.')[0]
                    DatabasePath = 
                    Logpath = 
                    SysvolPath = 
                }
    }    
}
$configData = @{}
 
$configData = @{
                AllNodes = @(
                              @{
                                 NodeName = 'localhost';
                                 PSDscAllowPlainTextPassword = $true
                                    }
                    )
               }
cd C:\DSC
LABDC  -DomainName $domainName `
       -machinename $machinename `
       -Password $localuser `
       -SafeModePW $SafeModePW `
       -firstDomainAdmin $firstDomainAdmin `
       -ConfigurationData $configData 
 

CD C:\dsc\LABDC
Start-DscConfiguration -path C:\DSC\LABDC -Verbose -ComputerName Localhost -wait -force -debug

#issues 
#Creds stored in cleartext in the MOF
#domain admin used local user account credentials instead of specified. 

