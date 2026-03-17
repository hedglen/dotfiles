# =============================================================================
#   PowerShell Profile — rjh
#   Managed via dotfiles: https://github.com/hedglen/dotfiles
# =============================================================================

# --- Prompt (Oh My Posh) ---
$Host.UI.RawUI.BackgroundColor = 'Black'
Clear-Host
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$HOME\dotfiles\oh-my-posh\hedglab.omp.json" | Invoke-Expression
}

# =============================================================================
#   Navigation
# =============================================================================

function c { Set-Location C:\ }
function d { Set-Location D:\ }
function tools { Set-Location "$HOME\tools" }
function psh { Set-Location C:\Tools\PowerShell }
function home { Set-Location $HOME }
function dots { Set-Location "$HOME\dotfiles" }

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

function Get-StartupList {
    Get-CimInstance Win32_StartupCommand |
    Select-Object Name, Command, Location, User |
    Sort-Object Name |
    Format-Table -AutoSize
}

function Get-UserTasks {
    Get-ScheduledTask |
    Where-Object { $_.TaskPath -notlike '\Microsoft*' } |
    Select-Object TaskName, TaskPath, State |
    Sort-Object TaskName |
    Format-Table -AutoSize
}

function Search-Startup {
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
                        $_.Name -match $Pattern -or
                        ($_.Value -as [string]) -match $Pattern
                    )
                } |
                Select-Object @{n = 'Path'; e = { $p } }, Name, Value
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
    @{n = 'Drive'; e = { "{0}:" -f $_.DriveLetter } },
    FileSystemLabel,
    FileSystem,
    @{n = 'SizeGB'; e = { [math]::Round($_.Size / 1GB, 1) } },
    @{n = 'FreeGB'; e = { [math]::Round($_.SizeRemaining / 1GB, 1) } } |
    Sort-Object Drive |
    Format-Table -AutoSize
}

function Get-Uptime {
    $os = Get-CimInstance Win32_OperatingSystem
    $lastBoot = $os.LastBootUpTime
    $span = (Get-Date) - $lastBoot
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
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    [PSCustomObject]@{
        OS       = $os.Caption
        Uptime   = Get-Uptime
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
    $status = git status --porcelain
    if (-not $status) {
        Write-Host "Nothing to save — dotfiles already up to date." -ForegroundColor DarkGray
    }
    else {
        git add -A
        git commit -m $Message
        git push
        Write-Host "Dotfiles saved to GitHub." -ForegroundColor Green
    }
    Pop-Location
}

# sync-dots — pull latest dotfiles from GitHub and re-apply configs (no app upgrades)
function sync-dots {
    & "$HOME\dotfiles\maintenance\update.ps1" -SkipApps
}

# =============================================================================
#   Media Organizer
# =============================================================================

function orgmed {
    $py  = "$HOME\projects\media-organizer\.venv\Scripts\python.exe"
    $scr = "$HOME\projects\media-organizer\organize.py"
    & $py $scr @args
}

function orgmedx {
    $py  = "$HOME\projects\media-organizer\.venv\Scripts\python.exe"
    $scr = "$HOME\projects\media-organizer\organize.py"
    & $py $scr --dest x --apply
}

# =============================================================================
#   Aliases
# =============================================================================

Set-Alias ll           Get-ChildItem
Set-Alias la           Get-ChildItem
Set-Alias open         Invoke-Item
Set-Alias startup-list Get-StartupList
Set-Alias tasks-user   Get-UserTasks
Set-Alias startup-find Search-Startup
Set-Alias uptime       Get-Uptime

# =============================================================================
#   PSReadLine
# =============================================================================

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -Colors @{ InlinePrediction = "#5555FF" }

# =============================================================================
#   Styling
# =============================================================================

$PSStyle.FileInfo.Directory = "`e[38;5;81m"   # soft cyan
$PSStyle.FileInfo.Executable = "`e[38;5;220m"  # warm yellow

# =============================================================================
#   Startup Banner
# =============================================================================

$esc = [char]27
[Console]::WriteLine("${esc}[38;5;129m  drives  uptime  sysinfo  users  admins  startup-list  tasks-user  pkillf  reload${esc}[0m")
[Console]::WriteLine("${esc}[38;5;129m  orgmed [--apply] [--dest x|movies|tv|music_videos]  orgmedx  -- organize D:\media\Downloads${esc}[0m")
[Console]::WriteLine("${esc}[38;5;129m  save-dots [message]  — commit & push dotfiles to GitHub${esc}[0m")
[Console]::WriteLine("${esc}[38;5;129m  sync-dots             — pull latest dotfiles & relink configs${esc}[0m")

$quotes = @(
    "You're not debugging. You're time travelling.",
    "AI writes code. You write the future.",
    "The bug you ignore today spawns tech debt tomorrow.",
    "Clarity comes not from code, but from thought before code.",
    "Refactor until it sings. Then refactor again."
)
[Console]::WriteLine("${esc}[38;2;255;96;0m  $(Get-Random -InputObject $quotes)${esc}[0m")
