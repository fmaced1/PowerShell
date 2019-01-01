param($username, $password, $command, $arguments = " ")

# Don't use c:\windows\temp below, as standard users don't have access to it
$errfile = "c:\users\public\runas_error.txt"
$outfile = "c:\users\public\runas_out.txt"
$envusername = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

write-host "Supplied Username  = " $username
write-host "Env Username  = " $envusername
write-host "Password  = " $password
write-host "Command   = " $command
write-host "Arguments = " $arguments
write-host "Outfile   = " $outfile
write-host "Errfile   = " $errfile

$securepassword = ConvertTo-SecureString -String $password -AsPlainText -Force;
$creds = New-Object System.Management.Automation.PSCredential($username,$securepassword)
$myfile = $MyInvocation.MyCommand.Definition

# Works with local and domain users
if (($env:username -eq $username) -or ($envusername -eq $username)) {
    #Run the actual command as the privileged user
    Start-Process -FilePath $command -ArgumentList $arguments -RedirectStandardOut $outfile -RedirectStandardError $errfile

    #Exit, or you'll have a loop
    exit
}

#We're not running as our intended user, respawn this script with creds
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$myfile`" $username `"$password`" `"$command`" `"$arguments`"" -Credential $creds 
