
param (
    [Parameter(Mandatory=$true)][string]$INC = $Args[0]
)

$COMPUTERS = Get-Content "C:\ARP\CRPA\Limpeza_Desktop\$INC.txt"
Get-Job|Remove-Job -Force
Write-Host "$INC"
$SCRIPT_USER = $env:UserName
$MY_HOSTNAME = $env:ComputerName
$SCRIPT_HOME = "\\???\ClearCacheRemotely\ClearCacheBatch\"
$SCRIPT_NAME = "ClearCacheBatch.bat"
$SCRIPT_BATCH = $SCRIPT_HOME + $SCRIPT_NAME
$INSTALL_LOG = $SCRIPT_HOME + "log-CCR.txt"
$AUTO_ID = "3"
function Get-TimeStamp { return "[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date) }

Write-Output "---" 
Write-Output "Login: $MYCRED"
Write-Output "Data: $(Get-TimeStamp)"
Write-Output "Hosts: $COMPUTERS"
Write-Output ""

ForEach ( $COMPUTER in $COMPUTERS) {
    If (Test-Connection $COMPUTER -count 1 -quiet) {
        $ERRORACTIONPREFERENCE = "silentlycontinue"
        $DOMAIN_NAME = [System.Net.Dns]::gethostentry($COMPUTER)
        if ($DOMAIN_NAME) { $SOURCE_STORE = Write-Output $DOMAIN_NAME.HostName | %{$_.split('.')[1]} } else { $SOURCE_STORE = "Fora do domínio" }
        Write-Host -f Yellow "Loja : $SOURCE_STORE Máquina : $COMPUTER" 
        $TMP_DIR = "\\$COMPUTER\c$\ClearCacheBatch\"
        if (!(Test-Path -path $TMP_DIR)) { New-Item $TMP_DIR -Type Directory 2>> $NULL }
        $TMP_BATCH = "\\$COMPUTER\c$\ClearCacheBatch\$SCRIPT_NAME"
        if (!(Test-Path $TMP_BATCH)) { Copy-Item $SCRIPT_BATCH \\$COMPUTER\c$\ClearCacheBatch\ 2>> $NULL;Start-Sleep -s 1 }
        $CUSTOM_JOB_NAME = "$COMPUTER.$INC"
        Invoke-Command -ComputerName $COMPUTER -ScriptBlock {param($SCRIPT_NAME) Trace-Command NativeCommandParameterBinder -Expression { & cmd.exe /c "C:\ClearCacheBatch\$SCRIPT_NAME"}} -Authentication negotiate -ArgumentList $SCRIPT_NAME -AsJob -JobName $CUSTOM_JOB_NAME >> $NULL
    } else {
        $OFF_POINTER = '1'
    }
}

While ($(Get-Job -Name "*$INC*").State -contains "Running") {
    $IP_RUNNING = $(Get-Job -State "Running").Location
    Write-Host "Executando na máquina : "
    Write-Host "$IP_RUNNING"
    Start-Sleep -s 30
}

$MY_POINTER = 1
$FINAL_STATE = $(Get-Job -Name "*.$INC*").State

while ( $FINAL_STATE -contains "NotStarted" -or $FINAL_STATE -contains "Failed" -or $FINAL_STATE -contains "Stopped" -or $FINAL_STATE -contains "Blocked" -or $FINAL_STATE -contains "Suspended" -or $FINAL_STATE -contains "Disconnected" -or $FINAL_STATE -contains "Suspending" -or $FINAL_STATE -contains "Stopping" -AND $MY_POINTER -le 5) {

    Write-Host " "
    Write-Host "Tentativa numero : $MY_POINTER"
    $MY_POINTER++
    $FAILED_COMPUTERS = $(Get-Job -State "Failed").Location
    $DISCONNECTED_COMPUTERS = $(Get-Job -State "Disconnected").Location
    
    ForEach ( $TRY_COMPUTER in $FAILED_COMPUTERS ) {
        $SLEEP_RANDOM = Get-Random -Minimum 2 -Maximum 11
        Write-Host " "
        Write-Host "A execução falhou aguardando $SLEEP_RANDOM segundos para a próxima tentativa."
        Start-Sleep -s $SLEEP_RANDOM
        Get-Job -Name "*$TRY_COMPUTER*"|Remove-Job -Force
        $ERRORACTIONPREFERENCE = "silentlycontinue"
        $DOMAIN_NAME = [System.Net.Dns]::gethostentry($TRY_COMPUTER)
        if ($DOMAIN_NAME) { $SOURCE_STORE = Write-Output $DOMAIN_NAME.HostName | %{$_.split('.')[1]} } else { $SOURCE_STORE = "Fora do domínio" }
        Write-Host -f Yellow "Loja : $SOURCE_STORE Máquina : $TRY_COMPUTER Falhou, tentando mais uma vez."
        $TMP_DIR = "\\$TRY_COMPUTER\c$\ClearCacheBatch\"
        if (!(Test-Path -path $TMP_DIR)) { New-Item $TMP_DIR -Type Directory 2>> $NULL }        
        $TMP_BATCH = "\\$TRY_COMPUTER\c$\ClearCacheBatch\$SCRIPT_NAME"
        if (!(Test-Path $TMP_BATCH)) { Copy-Item $SCRIPT_BATCH \\$TRY_COMPUTER\c$\ClearCacheBatch\ 2>> $NULL;Start-Sleep -s 1 }
        $CUSTOM_JOB_NAME = "$TRY_COMPUTER.$INC"
        Invoke-Command -ComputerName $TRY_COMPUTER -ScriptBlock {param($SCRIPT_NAME) Trace-Command NativeCommandParameterBinder -Expression { & cmd.exe /c "C:\ClearCacheBatch\$SCRIPT_NAME"}} -Authentication negotiate -ArgumentList $SCRIPT_NAME -AsJob -JobName $CUSTOM_JOB_NAME >> $NULL
     }

     ForEach ( $1TryComputer in $DISCONNECTED_COMPUTERS ) {
        $SLEEP_RANDOM = Get-Random -Minimum 600 -Maximum 900
        Write-Host " "
        Write-Host "A máquina $COMPUTER desconectou aguardando $SLEEP_RANDOM segundos para a próxima tentativa."
        Start-Sleep -s $SLEEP_RANDOM
        Get-Job -Name "*$1TryComputer*"|Remove-Job -Force
        $ERRORACTIONPREFERENCE = "silentlycontinue"
        $DOMAIN_NAME = [System.Net.Dns]::gethostentry($1TryComputer)
        if ($DOMAIN_NAME) { $SOURCE_STORE = Write-Output $DOMAIN_NAME.HostName | %{$_.split('.')[1]} } else { $SOURCE_STORE = "Fora do domínio" }
        Write-Host -f Yellow "Loja : $SOURCE_STORE Máquina : $1TryComputer Desconectou, tentando mais uma vez."
        $TMP_DIR = "\\$1TryComputer\c$\ClearCacheBatch\"
        if (!(Test-Path -path $TMP_DIR)) { New-Item $TMP_DIR -Type Directory 2>> $NULL }
        $TMP_BATCH = "\\$1TryComputer\c$\ClearCacheBatch\$SCRIPT_NAME"
        if (!(Test-Path $TMP_BATCH)) { Copy-Item $SCRIPT_BATCH \\$1TryComputer\c$\ClearCacheBatch\ 2>> $NULL;Start-Sleep -s 1 }
        $CUSTOM_JOB_NAME = "$1TryComputer.$INC"
        Invoke-Command -ComputerName $1TryComputer -ScriptBlock {param($SCRIPT_NAME) Trace-Command NativeCommandParameterBinder -Expression { & cmd.exe /c "C:\ClearCacheBatch\$SCRIPT_NAME"}} -Authentication negotiate -ArgumentList $SCRIPT_NAME -AsJob -JobName $CUSTOM_JOB_NAME >> $NULL
     

    While ($(Get-Job -Name "*.$INC*").State -contains "Running") {
        $IP_RUNNING = $(Get-Job -State "Running").Location
        Write-Host "Executando na máquina : "
        Write-Host "$IP_RUNNING"
        Start-Sleep -s 30
        }

    $FINAL_STATE = $(Get-Job -Name "*.$INC*").State
    }
}

$FINAL_STATE = $(Get-Job -Name "*$INC*").State
$SLEEP_RANDOM = Get-Random -Minimum 20 -Maximum 80

if ( $OFF_POINTER -eq '1' ) {
        while (get-process -name ProcessRunner) {
        Write-Host "Aguardando a disponibilidade do robô - Sleeping $SLEEP_RANDOM segundos"
        Start-Sleep -s $SLEEP_RANDOM
        }
    Write-Host "Do something here"
} else {
        while (get-process -name ProcessRunner) {
        Write-Host "Aguardando a disponibilidade do robô - Sleeping $SLEEP_RANDOM segundos"
        Start-Sleep -s $SLEEP_RANDOM
        }
    Write-Host "Do something here"
}

Remove-Item -Path "C:\ARP\CRPA\Limpeza_Desktop\$INC.txt" -Force
