# =============================================================================
#   dotfiles/install.ps1
#   Bootstrap a fresh Windows machine from scratch.
#   https://github.com/hedglen/dotfiles
#
#   Usage:
#     irm https://raw.githubusercontent.com/hedglen/dotfiles/master/install.ps1 | iex
#
#   Flags:
#     -AppsOnly     Only install winget apps
#     -ConfigsOnly  Only symlink config files
#     -NoApps       Skip app installation
#     -DryRun       Preview what would happen without doing anything
# =============================================================================

param(
    [switch]$AppsOnly,
    [switch]$ConfigsOnly,
    [switch]$NoApps,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$DotfilesDir = $PSScriptRoot

# If running via irm | iex, clone the repo first
if (-not $DotfilesDir -or $DotfilesDir -eq "") {
    $DotfilesDir = "$HOME\dotfiles"
    if (-not (Test-Path $DotfilesDir)) {
        Write-Host "Cloning dotfiles repo..." -ForegroundColor Cyan
        git clone https://github.com/hedglen/dotfiles.git $DotfilesDir
    }
    & "$DotfilesDir\install.ps1" @PSBoundParameters
    exit
}

# =============================================================================

function Write-Step { param([string]$Msg) Write-Host "`n>> $Msg" -ForegroundColor Cyan }
function Write-OK   { param([string]$Msg) Write-Host "   OK  $Msg" -ForegroundColor Green }
function Write-Skip { param([string]$Msg) Write-Host "   --  $Msg" -ForegroundColor DarkGray }
function Write-Warn { param([string]$Msg) Write-Host "   !!  $Msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "   dotfiles installer — hedglen" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
if ($DryRun) { Write-Host "   DRY RUN — no changes will be made" -ForegroundColor Yellow }
Write-Host ""

# =============================================================================
#   1. Prerequisites
# =============================================================================
Write-Step "Checking prerequisites"

$prereqs = @("git", "winget")
foreach ($cmd in $prereqs) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Write-OK "$cmd found"
    } else {
        Write-Warn "$cmd not found — some steps may fail"
    }
}

# =============================================================================
#   2. Install apps via winget
# =============================================================================
if (-not $ConfigsOnly -and -not $NoApps) {
    Write-Step "Installing apps from winget"

    $pkgFile = Join-Path $DotfilesDir "apps\winget-packages.json"
    if (Test-Path $pkgFile) {
        if ($DryRun) {
            Write-Skip "Would run: winget import -i $pkgFile"
        } else {
            winget import -i $pkgFile --accept-package-agreements --accept-source-agreements --ignore-versions
            Write-OK "Apps installed"
        }
    } else {
        Write-Warn "apps\winget-packages.json not found — skipping"
    }
}

# =============================================================================
#   3. Windows tweaks (optional — requires admin, skipped if not elevated)
# =============================================================================
if (-not $AppsOnly -and -not $ConfigsOnly) {
    Write-Step "Windows tweaks"
    $tweaksScript = Join-Path $DotfilesDir "windows\tweaks.ps1"
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Warn "Not running as admin — skipping tweaks. Re-run install.ps1 as admin, or run windows\tweaks.ps1 manually."
    } elseif (Test-Path $tweaksScript) {
        if ($DryRun) {
            Write-Skip "Would run: windows\tweaks.ps1"
        } else {
            & $tweaksScript
            Write-OK "Windows tweaks applied"
        }
    }
}

# =============================================================================
#   4. Symlink configs
# =============================================================================
if (-not $AppsOnly) {
    Write-Step "Linking config files"

    $configs = @(
        @{
            src  = "powershell\profile.ps1"
            dst  = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
            desc = "PowerShell profile"
        },
        @{
            src  = "git\.gitconfig"
            dst  = "$HOME\.gitconfig"
            desc = "Git config"
        },
        @{
            src  = "windows-terminal\settings.json"
            dst  = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
            desc = "Windows Terminal"
        },
        @{
            src  = "vscode\settings.json"
            dst  = "$HOME\AppData\Roaming\Code\User\settings.json"
            desc = "VS Code settings"
        },
        @{
            src  = "autohotkey\main.ahk"
            dst  = "$HOME\dotfiles-ahk\main.ahk"
            desc = "AutoHotkey script"
        }
    )

    foreach ($c in $configs) {
        $src    = Join-Path $DotfilesDir $c.src
        $dst    = $c.dst
        $dstDir = Split-Path $dst -Parent

        if (-not (Test-Path $src)) {
            Write-Warn "$($c.desc): source not found ($src)"
            continue
        }

        if ($DryRun) {
            Write-Skip "$($c.desc): $src -> $dst"
            continue
        }

        # Ensure destination directory exists
        if (-not (Test-Path $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }

        # Back up existing file
        if (Test-Path $dst) {
            $backup = "$dst.backup"
            Copy-Item $dst $backup -Force
            Remove-Item $dst -Force
            Write-Host "   Backed up existing to $backup" -ForegroundColor DarkGray
        }

        # Try symlink first, fall back to copy
        try {
            New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
            Write-OK "$($c.desc) (symlinked)"
        } catch {
            Copy-Item $src $dst -Force
            Write-Warn "$($c.desc) (copied — run as admin for symlinks)"
        }
    }
}

# =============================================================================
#   5. VS Code extensions
# =============================================================================
if (-not $AppsOnly) {
    Write-Step "VS Code extensions"
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $extFile = Join-Path $DotfilesDir "vscode\extensions.txt"
        if (Test-Path $extFile) {
            Get-Content $extFile |
            Where-Object { $_.Trim() -ne '' -and $_ -notmatch '^\s*#' } |
            ForEach-Object {
                $ext = $_.Trim()
                if ($DryRun) {
                    Write-Skip "Would install: $ext"
                } else {
                    code --install-extension $ext --force 2>&1 | Out-Null
                    Write-OK $ext
                }
            }
        }
    } else {
        Write-Warn "VS Code (code) not on PATH — skipping extensions"
    }
}

# =============================================================================
#   6. mpv config
# =============================================================================
Write-Step "mpv config"
$mpvDir = "C:\mpv"
if (Test-Path "$mpvDir\portable_config") {
    Write-Skip "Already installed at $mpvDir\portable_config"
} elseif (Test-Path $mpvDir) {
    if ($DryRun) {
        Write-Skip "Would clone mpv-config into $mpvDir\portable_config"
    } else {
        git clone https://github.com/hedglen/mpv-config.git "$mpvDir\portable_config"
        Write-OK "mpv config cloned"
    }
} else {
    Write-Warn "mpv not found at $mpvDir — run install.ps1 from mpv-config repo first"
    Write-Warn "  irm https://raw.githubusercontent.com/hedglen/mpv-config/master/install.ps1 | iex"
}

# =============================================================================
#   7. AutoHotkey — register on startup
# =============================================================================
if (-not $AppsOnly) {
    Write-Step "AutoHotkey startup"
    $ahkSrc = Join-Path $DotfilesDir "autohotkey\main.ahk"
    $ahkExe = (Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue)?.Source
    if (-not $ahkExe) {
        $ahkExe = "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey64.exe"
    }
    if (Test-Path $ahkSrc) {
        $runKey  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
        $runVal  = "`"$ahkExe`" `"$ahkSrc`""
        if ($DryRun) {
            Write-Skip "Would register AHK in Run: $runVal"
        } else {
            Set-ItemProperty -Path $runKey -Name 'AutoHotkey' -Value $runVal -Force
            # Launch it now too
            if (Get-Process -Name 'AutoHotkey*' -ErrorAction SilentlyContinue) {
                Stop-Process -Name 'AutoHotkey*' -Force -ErrorAction SilentlyContinue
            }
            Start-Process $ahkExe $ahkSrc
            Write-OK "AutoHotkey registered for startup and launched"
        }
    } else {
        Write-Warn "autohotkey\main.ahk not found — skipping"
    }
}

# =============================================================================
#   Done
# =============================================================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "   All done!" -ForegroundColor Magenta
Write-Host "   Restart your terminal to apply changes." -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""
