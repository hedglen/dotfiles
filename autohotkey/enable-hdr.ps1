$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\VideoSettings'
if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
Set-ItemProperty -Path $path -Name EnableHDROutput -Value 1 -Type DWord -Force
