pwd                             => Get-Location
ls -ltr                         => Get-ChildItem $env:USERPROFILE\Desktop | Sort-Object -Property LastWriteTime
find . -type f -iname "azure"   => Get-ChildItem -Filter "*azure*" -Recurse -File
cp -R Tools ~/                  => Copy-Item -Path '.\Tools\' -Destination $env:USERPROFILE -Recurse
rm -rf                          => Remove-Item -Recurse -Force
mkdir -p                        => New-Item -ItemType Directory -Name 'MyNewFolder'
touch MyFile{1..4}              => 1..4 | ForEach-Object { New-Item -ItemType File -Name "MyFile$_" }
cat                             => Get-Content
tail -n7 ./MyFile1              => Get-Content -Tail 7 .\MyFile1 (PowerShell +3.0)
1. grep                         => Get-Process | Where-Object { $_.WorkingSet -gt 104857600 }
2. grep                         => Select-String -Path 'C:\Windows\iis.log' -Pattern 'Failed'
uname -a                        => $Properties = 'Caption', 'CSName', 'Version', 'BuildType', 'OSArchitecture'; Get-CimInstance Win32_OperatingSystem | Select-Object $Properties | Format-Table -AutoSize
mkfs                            => New-Volume or Format-Volume
ping                            => Test-Connection 192.168.0.21 | Format-Table -AutoSize
man                             => Get-Help Stop-Service -Full or Get-Help "about_regular*"
cut                             => Get-ChildItem $env:USERPROFILE\Desktop -Filter "*.ps1" | Select-Object -Property 'Name', 'Length'
