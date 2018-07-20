## This script is to manually download the Kaseya agent for a specific customer and install it on a remote server. 
## This script requires WinRM to be enabled and Secure Intenet Browing is turned off on the server. The script leverages IE by default. 

## Specify the servers you want to install the agent on. 
$servers="SOMESERVER"

## This runs the commands in parallel on servers specified above. A ForEach command would run serially. 
Invoke-command -ComputerName $servers -ScriptBlock {
## You can have get this URL from the manual download for the specific customer. The ID number is critical. You have to browse the "Deploy Agent URL" and copy the 
## "Click here of Agent doesn't.." URL 
$url = "https:/XXX.XXX.XXX.com:443/mkDefault.asp?id=43125711"
$output = "C:\users\####\kagent.exe"
#### Uses a .NET call to downoad the file. Slightly faster than Invoke-WebRequest. 
(New-Object System.Net.WebClient).DownloadFile($url, $output)
### This is supposed to install the agent. For some reason, it doesn't work in the script. If you connect to the server directly using Enter-PSSESSion,
C:\users\####\kagent.exe /s}