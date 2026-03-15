# =============================================================================
#   PowerShell Profile — rjh
#   Managed via dotfiles: https://github.com/hedglen/dotfiles
# =============================================================================

# --- Custom Prompt ---
function prompt {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).
        IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $tag = if ($isAdmin) { "[ADMIN]" } else { "[USER]" }
    $time = (Get-Date).ToString("HH:mm")
    $path = $executionContext.SessionState.Path.CurrentLocation
    Write-Host "$tag $time " -NoNewline -ForegroundColor DarkGray
    Write-Host "PS " -NoNewline -ForegroundColor Magenta
    Write-Host "$path" -NoNewline -ForegroundColor Yellow  # maps to brightYellow = #FF8C00
    return "`n> "
}

# =============================================================================
#   Navigation
# =============================================================================

function c     { Set-Location C:\ }
function d     { Set-Location D:\ }
function tools { Set-Location C:\Tools }
function psh   { Set-Location C:\Tools\PowerShell }
function home  { Set-Location $HOME }
function dots  { Set-Location "$HOME\dotfiles" }

# =============================================================================
#   System / User Helpers
# =============================================================================

function users {
    Get-LocalUser |
        Select-Object Name, Enabled, LastLogon |
        Format-Table -AutoSize
}

function admins {
    Get-LocalGroupMember Administrators |
        Select-Object ObjectClass, Name, PrincipalSource |
        Format-Table -AutoSize
}

# =============================================================================
#   Startup / Task Inspection
# =============================================================================

function startup-list {
    Get-CimInstance Win32_StartupCommand |
        Select-Object Name, Command, Location, User |
        Sort-Object Name |
        Format-Table -AutoSize
}

function tasks-user {
    Get-ScheduledTask |
        Where-Object { $_.TaskPath -notlike '\Microsoft*' } |
        Select-Object TaskName, TaskPath, State |
        Sort-Object TaskName |
        Format-Table -AutoSize
}

function startup-find {
    param([Parameter(Mandatory = $true)][string]$Pattern)
    $paths = @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce'
    )
    $result = foreach ($p in $paths) {
        if (Test-Path $p) {
            Get-ItemProperty $p | ForEach-Object {
                $_.PSObject.Properties |
                    Where-Object {
                        $_.Name -notmatch '^PS' -and (
                            $_.Name  -match $Pattern -or
                            ($_.Value -as [string]) -match $Pattern
                        )
                    } |
                    Select-Object @{n='Path';e={$p}}, Name, Value
            }
        }
    }
    if ($result) { $result | Format-Table -AutoSize }
    else { Write-Host "No startup entries matched: $Pattern" -ForegroundColor Yellow }
}

# =============================================================================
#   Daily Driver Helpers
# =============================================================================

function drives {
    Get-Volume |
        Where-Object DriveLetter |
        Select-Object `
            @{n='Drive'; e={"{0}:" -f $_.DriveLetter}},
            FileSystemLabel,
            FileSystem,
            @{n='SizeGB'; e={[math]::Round($_.Size / 1GB, 1)}},
            @{n='FreeGB'; e={[math]::Round($_.SizeRemaining / 1GB, 1)}} |
        Sort-Object Drive |
        Format-Table -AutoSize
}

function uptime {
    $os       = Get-CimInstance Win32_OperatingSystem
    $lastBoot = $os.LastBootUpTime
    $span     = (Get-Date) - $lastBoot
    "{0}d {1}h {2}m" -f $span.Days, $span.Hours, $span.Minutes
}

function pkillf {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [switch]$WhatIf
    )
    $targets = Get-Process | Where-Object { $_.ProcessName -like "*$Name*" }
    if (-not $targets) {
        Write-Host "No matching processes for: $Name" -ForegroundColor Yellow
        return
    }
    $targets | Select-Object ProcessName, Id | Sort-Object ProcessName, Id | Format-Table -AutoSize
    if ($WhatIf) { return }
    $targets | Stop-Process -Force
    Write-Host "Stopped: $Name" -ForegroundColor Green
}

# sysinfo — quick hardware/OS snapshot
function sysinfo {
    $os  = Get-CimInstance Win32_OperatingSystem
    $cs  = Get-CimInstance Win32_ComputerSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    [PSCustomObject]@{
        OS       = $os.Caption
        Uptime   = uptime
        RAM_GB   = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
        CPU      = $cpu.Name
        User     = "$env:USERDOMAIN\$env:USERNAME"
        Hostname = $env:COMPUTERNAME
    } | Format-List
}

# which — find command location (alias for Get-Command)
function which { param([string]$Name) (Get-Command $Name -ErrorAction SilentlyContinue)?.Source }

# touch — create empty file like Unix touch
function touch { param([string]$Path) New-Item -ItemType File -Path $Path -Force | Out-Null }

# grep — pipe-friendly wrapper
function grep { param([string]$Pattern) $input | Select-String $Pattern }

# reload — re-source the profile
function reload { . $PROFILE; Write-Host "Profile reloaded." -ForegroundColor Green }

# save-dots — commit and push all dotfile changes to GitHub
function save-dots {
    param([string]$Message = "update configs")
    Push-Location "$HOME\dotfiles"
    git add -A
    $status = git status --porcelain
    if (-not $status) {
        Write-Host "Nothing to save — dotfiles already up to date." -ForegroundColor DarkGray
    } else {
        git commit -m $Message
        git push
        Write-Host "Dotfiles saved to GitHub." -ForegroundColor Green
    }
    Pop-Location
}

# =============================================================================
#   Aliases
# =============================================================================

Set-Alias ll   Get-ChildItem
Set-Alias la   Get-ChildItem
Set-Alias open Invoke-Item

# =============================================================================
#   Styling
# =============================================================================

$PSStyle.FileInfo.Directory  = "`e[38;5;81m"   # soft cyan
$PSStyle.FileInfo.Executable = "`e[38;5;220m"  # warm yellow

# =============================================================================
#   Startup Banner
# =============================================================================

Write-Host "  drives  uptime  sysinfo  users  admins  startup-list  tasks-user  pkillf  reload" -ForegroundColor DarkGray
Write-Host "  save-dots [message]  — commit & push dotfiles to GitHub" -ForegroundColor DarkGray
