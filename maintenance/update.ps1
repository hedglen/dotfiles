# =============================================================================
#   dotfiles/maintenance/update.ps1
#   Keep a running machine in sync with your dotfiles repo.
#
#   Usage:
#     .\maintenance\update.ps1           # full update
#     .\maintenance\update.ps1 -SkipApps # pull + relink + extensions, no winget upgrade
#     .\maintenance\update.ps1 -SkipDots # upgrade apps only, skip git pull
#     .\maintenance\update.ps1 -DryRun   # preview without making changes
#
#   Tip: use `sync-dots` from your PowerShell profile for the quick version.
# =============================================================================

param(
    [switch]$SkipApps,
    [switch]$SkipDots,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$DotfilesDir = Split-Path $PSScriptRoot -Parent

function Write-Step { param([string]$Msg) Write-Host "`n>> $Msg" -ForegroundColor Cyan }
function Write-OK   { param([string]$Msg) Write-Host "   OK  $Msg" -ForegroundColor Green }
function Write-Skip { param([string]$Msg) Write-Host "   --  $Msg" -ForegroundColor DarkGray }
function Write-Warn { param([string]$Msg) Write-Host "   !!  $Msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "   dotfiles updater -- hedglen" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
if ($DryRun) { Write-Host "   DRY RUN -- no changes will be made" -ForegroundColor Yellow }
Write-Host ""

# =============================================================================
#   1. Pull dotfiles
# =============================================================================
if (-not $SkipDots) {
    Write-Step "Pulling dotfiles from GitHub"
    Push-Location $DotfilesDir

    $dirty = git status --porcelain
    if ($dirty) {
        Write-Warn "Uncommitted changes detected -- skipping pull to avoid conflicts."
        Write-Warn "Run 'save-dots' first, or stash your changes manually."
    } elseif ($DryRun) {
        Write-Skip "Would run: git pull"
    } else {
        git pull
        Write-OK "Dotfiles up to date"
    }

    Pop-Location
}

# =============================================================================
#   2. Re-link configs (non-destructive -- skips valid existing symlinks)
# =============================================================================
Write-Step "Config symlinks"

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
        src  = "yt-dlp\config"
        dst  = "$env:APPDATA\yt-dlp\config"
        desc = "yt-dlp config"
    }
)

foreach ($c in $configs) {
    $src = Join-Path $DotfilesDir $c.src
    $dst = $c.dst

    if (-not (Test-Path $src)) {
        Write-Warn "$($c.desc): source not found ($src)"
        continue
    }

    # Check if symlink already points to the right place
    if (Test-Path $dst) {
        $item = Get-Item $dst -Force
        if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $src) {
            Write-Skip "$($c.desc): already linked"
            continue
        }
    }

    if ($DryRun) {
        Write-Skip "$($c.desc): would link $src -> $dst"
        continue
    }

    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }

    if (Test-Path $dst -ErrorAction SilentlyContinue) {
        $existing = Get-Item $dst -Force -ErrorAction SilentlyContinue
        if ($existing -and $existing.LinkType -eq 'SymbolicLink') {
            Remove-Item $dst -Force
        } elseif ($existing) {
            Copy-Item $dst "$dst.backup" -Force
            Remove-Item $dst -Force
            Write-Host "   Backed up existing to $dst.backup" -ForegroundColor DarkGray
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
        Write-OK "$($c.desc) (symlinked)"
    } catch {
        Copy-Item $src $dst -Force
        Write-Warn "$($c.desc) (copied -- run as admin for symlinks)"
    }
}

# =============================================================================
#   3. VS Code extensions -- install only new ones
# =============================================================================
Write-Step "VS Code extensions"

$codeCmd = "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
if (-not (Test-Path $codeCmd)) { $codeCmd = "code" }
if (Get-Command $codeCmd -ErrorAction SilentlyContinue) {
    $extFile = Join-Path $DotfilesDir "vscode\extensions.txt"
    if (Test-Path $extFile) {
        $installed = & $codeCmd --list-extensions 2>$null | ForEach-Object { $_.ToLower() }
        $wanted = Get-Content $extFile |
            Where-Object { $_.Trim() -ne '' -and $_ -notmatch '^\s*#' } |
            ForEach-Object { $_.Trim() }

        $toInstall = $wanted | Where-Object { $installed -notcontains $_.ToLower() }

        if (-not $toInstall) {
            Write-Skip "All extensions already installed"
        } else {
            foreach ($ext in $toInstall) {
                if ($DryRun) {
                    Write-Skip "Would install: $ext"
                } else {
                    & $codeCmd --install-extension $ext --force 2>&1 | Out-Null
                    Write-OK $ext
                }
            }
        }
    }
} else {
    Write-Warn "VS Code (code) not on PATH -- skipping"
}

# =============================================================================
#   4. Fonts -- install if missing
# =============================================================================
Write-Step "Fonts"

$fontsDir  = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$regPath   = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
$checkFont = 'CaskaydiaCove Nerd Font Regular (TrueType)'

# Check HKCU first, then HKLM (system-wide install), then fallback to file presence
$installed = (Get-ItemProperty $regPath -ErrorAction SilentlyContinue).$checkFont
if (-not $installed) {
    $installed = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -ErrorAction SilentlyContinue).$checkFont
}
if (-not $installed) {
    $fontFile = Get-ChildItem "$fontsDir\CaskaydiaCove*" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($fontFile) { $installed = $fontFile.FullName }
}

if ($installed) {
    Write-Skip "CaskaydiaCove Nerd Font already installed"
} elseif ($DryRun) {
    Write-Skip "Would download and install CaskaydiaCove Nerd Font"
} else {
    $tmpZip     = "$env:TEMP\CascadiaCode.zip"
    $tmpExtract = "$env:TEMP\CascadiaCode-nf"
    $fontUrl    = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"

    Write-Host "   Downloading CaskaydiaCove Nerd Font..." -ForegroundColor DarkGray
    Invoke-WebRequest -Uri $fontUrl -OutFile $tmpZip -UseBasicParsing
    Expand-Archive -Path $tmpZip -DestinationPath $tmpExtract -Force

    if (-not (Test-Path $fontsDir)) { New-Item -ItemType Directory -Path $fontsDir -Force | Out-Null }

    $count = 0
    Get-ChildItem $tmpExtract -Filter "*.ttf" | ForEach-Object {
        $dst = Join-Path $fontsDir $_.Name
        Copy-Item $_.FullName $dst -Force
        $fontName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) + " (TrueType)"
        Set-ItemProperty -Path $regPath -Name $fontName -Value $dst -Force
        $count++
    }

    Remove-Item $tmpZip, $tmpExtract -Recurse -Force -ErrorAction SilentlyContinue
    Write-OK "Installed $count font files"
}

# =============================================================================
#   5. Upgrade apps via winget
# =============================================================================
if (-not $SkipApps) {
    Write-Step "Upgrading apps (winget)"
    if ($DryRun) {
        Write-Skip "Would run: winget upgrade --all"
    } else {
        winget upgrade --all --accept-package-agreements --accept-source-agreements
        Write-OK "Apps upgraded"
    }
}

# =============================================================================
#   Done
# =============================================================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "   All done!" -ForegroundColor Magenta
if (-not $SkipApps -and -not $DryRun) {
    Write-Host "   Restart your terminal if the profile changed." -ForegroundColor Magenta
}
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""
