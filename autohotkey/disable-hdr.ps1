$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\VideoSettings'
if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
Set-ItemProperty -Path $path -Name EnableHDROutput -Value 0 -Type DWord -Force
