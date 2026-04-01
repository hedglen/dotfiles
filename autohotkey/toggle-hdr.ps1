$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\VideoSettings'
if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
$val = (Get-ItemProperty $path -Name EnableHDROutput -ErrorAction SilentlyContinue).EnableHDROutput
$new = if ($val -eq 1) { 0 } else { 1 }
Set-ItemProperty -Path $path -Name EnableHDROutput -Value $new -Type DWord -Force
