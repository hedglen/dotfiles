# =============================================================================
# windows/tweaks.ps1
# Windows privacy and quality-of-life tweaks.
# Run as Administrator.
#
# Usage:
#   .\tweaks.ps1          # apply everything
#   .\tweaks.ps1 -WhatIf  # preview without changing anything
# =============================================================================
param([switch]$WhatIf)

# --- Admin check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Run this script as Administrator." -ForegroundColor Red
    exit 1
}

# --- Helpers ---
function Set-Reg {
    param($Path, $Name, $Value, $Type = 'DWord')
    if ($WhatIf) { Write-Host "  [WHATIF] $Path\$Name = $Value" -ForegroundColor DarkGray; return }
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
}

function Disable-Svc {
    param($Name, $Label)
    $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if (-not $svc) { Write-Host "  skip $Label (not found)" -ForegroundColor DarkGray; return }
    if ($WhatIf) { Write-Host "  [WHATIF] Disable service: $Label" -ForegroundColor DarkGray; return }
    Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
    Set-Service -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "  OK $Label disabled" -ForegroundColor Green
}

function Write-Section { param($Title) Write-Host "`n[ $Title ]" -ForegroundColor Cyan }
function Write-OK      { param($Msg)   Write-Host "  OK $Msg"  -ForegroundColor Green }

if ($WhatIf) { Write-Host "`n  DRY RUN — no changes will be made`n" -ForegroundColor Yellow }


# =============================================================================
# Power Plan
# =============================================================================
Write-Section "Power"

$hp = Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerPlan |
      Where-Object { $_.ElementName -eq 'High performance' }
if ($hp) {
    $guid = $hp.InstanceID -replace '.*\{([^}]+)\}.*', '$1'
    if (-not $WhatIf) { powercfg /setactive $guid }
    Write-OK "High Performance power plan activated"
} else {
    if (-not $WhatIf) { powercfg /setactive SCHEME_MIN }
    Write-OK "High Performance plan set (fallback)"
}

# Disable fast startup (causes issues with drives, dual-boot, wake)
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' 'HiberbootEnabled' 0
Write-OK "Fast startup disabled"

# Disable sleep on AC
if (-not $WhatIf) { powercfg /change standby-timeout-ac 0 }
Write-OK "AC sleep disabled"

if (-not $WhatIf) { powercfg /change disk-timeout-ac 0 }
Write-OK "Disk sleep disabled"


# =============================================================================
# Privacy — Telemetry
# =============================================================================
Write-Section "Privacy — Telemetry"

Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'              'AllowTelemetry'    0
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry'  0
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'MaxTelemetryAllowed' 0
Disable-Svc 'DiagTrack'        'Connected User Experiences & Telemetry'
Disable-Svc 'dmwappushservice' 'WAP Push Message Routing'
Write-OK "Telemetry minimized"


# =============================================================================
# Privacy — Advertising & Activity
# =============================================================================
Write-Section "Privacy — Advertising"

Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'    'Enabled'                                  0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy'            'TailoredExperiencesWithDiagnosticDataEnabled' 0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'                   'EnableActivityFeed'     0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'                   'PublishUserActivities'  0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'                   'UploadUserActivities'   0
Write-OK "Advertising ID disabled"
Write-OK "Activity history / Timeline disabled"


# =============================================================================
# Privacy — App Permissions
# =============================================================================
Write-Section "Privacy — App Permissions"

# NOTE: We do NOT globally block camera/mic/location via policy here.
# Windows' built-in per-app permission prompts (Settings > Privacy) are
# the right mechanism — they let you grant or revoke access app-by-app
# without locking out the Settings UI.
# If you want to tighten a specific app, do so in Settings > Privacy & security.

Write-OK "App permissions: using Windows built-in per-app controls (no policy override)"


# =============================================================================
# Game Bar / Background Recording (NOT Xbox services)
# =============================================================================
Write-Section "Game DVR / Game Bar"

Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'       'AllowGameDVR'       0
Set-Reg 'HKCU:\System\GameConfigStore'                             'GameDVR_Enabled'    0
Set-Reg 'HKCU:\Software\Microsoft\GameBar'                         'AutoGameModeEnabled' 0

# NOTE: XblAuthManager / XblGameSave / XboxNetApiSvc are left alone.
# Disabling them breaks Xbox/Game Pass titles even without a Game Bar.

Write-OK "Background recording / Game DVR disabled (Xbox services untouched)"


# =============================================================================
# Explorer — Quality of Life
# =============================================================================
Write-Section "Explorer"

$explorerAdv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$explorerKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'

Set-Reg $explorerAdv 'HideFileExt'          0  # Show file extensions
Set-Reg $explorerAdv 'Hidden'               1  # Show hidden files
Set-Reg $explorerAdv 'LaunchTo'             1  # Open to This PC, not Quick Access
Set-Reg $explorerAdv 'NavPaneShowAllFolders' 0
Set-Reg $explorerKey 'ShowRecent'           0  # No recent files in Quick Access
Set-Reg $explorerKey 'ShowFrequent'         0  # No frequent folders in Quick Access

Write-OK "File extensions visible"
Write-OK "Hidden files visible"
Write-OK "Explorer opens to This PC"
Write-OK "Quick Access clutter removed"


# =============================================================================
# Start Menu / Search / Taskbar
# =============================================================================
Write-Section "Start / Search / Taskbar"

$search = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
$cdm    = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
$feeds  = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds'

Set-Reg $search 'BingSearchEnabled'  0  # No web results in Start search
Set-Reg $search 'CortanaConsent'     0  # Disable Cortana
Set-Reg $feeds  'EnableFeeds'        0  # Disable news/interests widget

Set-Reg $cdm 'ContentDeliveryAllowed'          0
Set-Reg $cdm 'OemPreInstalledAppsEnabled'      0
Set-Reg $cdm 'PreInstalledAppsEnabled'         0
Set-Reg $cdm 'SilentInstalledAppsEnabled'      0
Set-Reg $cdm 'SoftLandingEnabled'              0
Set-Reg $cdm 'SubscribedContent-338388Enabled' 0
Set-Reg $cdm 'SubscribedContent-338389Enabled' 0
Set-Reg $cdm 'SystemPaneSuggestionsEnabled'    0

Write-OK "Bing / web search in Start: off"
Write-OK "Cortana: off"
Write-OK "News / Interests widget: off"
Write-OK "Suggested / promoted apps: off"


# =============================================================================
# Unnecessary Services
# =============================================================================
Write-Section "Unnecessary Services"

Disable-Svc 'MapsBroker'  'Downloaded Maps Manager'
Disable-Svc 'RetailDemo'  'Retail Demo Service'

# Windows Search indexing — comment this IN only if you never use Start/file search.
# Disabling it silently breaks search across the whole OS.
# Disable-Svc 'WSearch' 'Windows Search (indexing)'


# =============================================================================
# Restart Explorer to apply visual changes
# =============================================================================
Write-Section "Applying"

if (-not $WhatIf) {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 800
    Start-Process explorer
    Write-OK "Explorer restarted"
}

Write-Host ""
Write-Host "  All tweaks applied." -ForegroundColor Magenta
Write-Host "  Restart your PC for service changes to fully take effect." -ForegroundColor Yellow
Write-Host ""
