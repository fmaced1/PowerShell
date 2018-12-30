param (
    [Parameter(Mandatory=$true)][string]$INC = $Args[0]
)

$MyArguments = '-noprofile -NoExit -WindowStyle Maximized -file "C:\???\ClearCacheRemotely.ps1" -INC ' + $INC
Start-Process powershell -ArgumentList $MyArguments -verb RunAs
