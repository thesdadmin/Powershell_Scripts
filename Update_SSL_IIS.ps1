## Declaring the PFS file with a private key and password for import.Password and Private key not required in some cases.
$SSL_Cert = Get-item "C:\Users\rpittman\Desktop\wilcard_mmclinic_com.pfx" 

## Declarre computers in the Web Farm to be updated 
$computers= "TWBUS01","TWBUS02","TWMSG01","TWMSG02","TWPRINT01","TWPRINT02"

## modify each computer 
foreach ($com in $computers){
## create Directory for the Certificate

Invoke-Command -ComputerName $com -ScriptBlock {mkdir "C:\SSL" }

##Copy cert to directory created
Copy-item $SSL_Cert.FullName -Destination "\\$com\c$\SSL" 
##Import Certificate on each computer
Invoke-Command -ComputerName $com -ScriptBlock {
##Have to declare the password variable here securely. Could not find a way to pass the variable from my computer to the session. 
$mypwd = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'
$certificate=Import-PfxCertificate -FilePath C:\ssl\wilcard_mmclinic_com.pfx -CertStoreLocation Cert:\LocalMachine\my -Password $mypwd.Password }
## You have to import the IIS Snapin to modify the IIS virtual drive
Get-Module -listavailable -name "WebAdministration" | Import-Module
#Had issues with IIS Module, have to delay to wait for it to import. 
Sleep -Seconds 2
## Modify the SSL Bindings for the Default Web site 
$certificate | Set-Item "IIS:\\SslBindings\0.0.0.0!443"
}}

#Verify SSL Thumbprint has changed. 
Invoke-Command -ComputerName $computers -ScriptBlock {Get-Module -listavailable -name "WebAdministration" |Import-Module 
Start-sleep 2 
Get-Item "IIS:\\SslBindings\0.0.0.0!443" Select PSComputerName,Thumbprint,PSChildName}