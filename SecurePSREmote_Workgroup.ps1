## Install a certificate on Workgroup server and lock down PSRemoting
### Import PFX certificate and enter private key password
$password = ConvertTo-SecureString -String <cert password> -AsPlainText -Force 
$cert = Import-PfxCertificate -FilePath <path to certificate> -CertStoreLocation Cert:\LocalMachine\My -Password $password 

##Create Secure WSMAN listener
New-Item -Path WSMan:\Localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint $cert.Thumbprint

##Create Firewall rule for PSRemoting over SSL 
New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "WinRM HTTPS-In" -Profile Any -LocalPort 5986 -Protocol TCP

##Remove HTTP listener
Get-ChildItem WSMan:\Localhost\Listener | Where -Property Keys -eq "Transport=HTTP" | Remove-Item -Recurse

##Deny unencrypted connections.
winrm set winrm/config/service @{AllowUnencrypted="false"}
