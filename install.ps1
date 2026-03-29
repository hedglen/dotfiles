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
    $DotfilesDir = "$HOME\workstation\dotfiles"
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
#   2. Clone workspace repos
# =============================================================================
if (-not $AppsOnly -and -not $ConfigsOnly) {
    Write-Step "Cloning workspace repos"

    $workspaceRepos = @(
        @{ url = "https://github.com/hedglen/scripts.git";  dst = "$HOME\workstation\scripts"         },
        @{ url = "https://github.com/hedglen/docs.git";     dst = "$HOME\workstation\docs"            },
        @{ url = "https://github.com/hedglen/hedglen.git";  dst = "$HOME\workstation\hedglen-profile" },
        @{ url = "https://github.com/hedglen/notes.git";    dst = "$HOME\workstation\notes"           }
    )

    foreach ($r in $workspaceRepos) {
        $name = Split-Path $r.dst -Leaf
        if (Test-Path $r.dst) {
            Write-Skip "$name already present"
        } elseif ($DryRun) {
            Write-Skip "Would clone $($r.url) → $($r.dst)"
        } else {
            try {
                git clone $r.url $r.dst
                Write-OK "$name cloned"
            } catch {
                Write-Warn "Failed to clone $name — $_"
            }
        }
    }

    $projectsDir = "$HOME\workstation\projects"
    if (Test-Path $projectsDir) {
        Write-Skip "projects dir already present"
    } elseif ($DryRun) {
        Write-Skip "Would create: $projectsDir"
    } else {
        New-Item -ItemType Directory -Path $projectsDir -Force | Out-Null
        Write-OK "projects dir created"
    }

    $toolsDir = "$HOME\workstation\tools"
    if (Test-Path $toolsDir) {
        Write-Skip "tools dir already present"
    } elseif ($DryRun) {
        Write-Skip "Would create: $toolsDir"
    } else {
        New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
        Write-OK "tools dir created"
    }
}

# =============================================================================
#   3. Install apps via winget
# =============================================================================
if (-not $ConfigsOnly -and -not $NoApps) {
    Write-Step "Installing apps from winget"

    $pkgFile = Join-Path $DotfilesDir "apps\winget-packages.json"
    if (Test-Path $pkgFile) {
        if ($DryRun) {
            Write-Skip "Would run: winget import -i $pkgFile"
        } else {
            try {
                winget import -i $pkgFile --accept-package-agreements --accept-source-agreements --ignore-versions
                Write-OK "Apps installed"
            } catch {
                Write-Warn "winget import finished with errors (some packages may have failed) — $_"
            }
        }
    } else {
        Write-Warn "apps\winget-packages.json not found — skipping"
    }
}

# =============================================================================
#   4. Windows tweaks (optional — requires admin, skipped if not elevated)
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
#   5. Symlink configs
# =============================================================================
if (-not $AppsOnly) {
    Write-Step "Linking config files"

    $configs = @(
        @{
            src  = "powershell\profile.ps1"
            dst  = $PROFILE.CurrentUserCurrentHost
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
            src  = "vscode\settings.json"
            dst  = "$HOME\AppData\Roaming\Cursor\User\settings.json"
            desc = "Cursor settings"
        },
        @{
            src  = "yt-dlp\config"
            dst  = "$env:APPDATA\yt-dlp\config"
            desc = "yt-dlp config"
        },
        @{
            src  = "wezterm\wezterm.lua"
            dst  = "$HOME\.wezterm.lua"
            desc = "WezTerm"
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

        # Skip if symlink already points to the right place
        $existingTarget = (Get-Item $dst -ErrorAction SilentlyContinue).Target
        if ($existingTarget -eq $src) {
            Write-Skip "$($c.desc) already linked"
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
#   6. VS Code extensions
# =============================================================================
if (-not $AppsOnly) {
    Write-Step "VS Code extensions"
    $codeCmd = "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
    if (-not (Test-Path $codeCmd)) { $codeCmd = "code" }
    if (Get-Command $codeCmd -ErrorAction SilentlyContinue) {
        $extFile = Join-Path $DotfilesDir "vscode\extensions.txt"
        if (Test-Path $extFile) {
            Get-Content $extFile |
            Where-Object { $_.Trim() -ne '' -and $_ -notmatch '^\s*#' } |
            ForEach-Object {
                $ext = $_.Trim()
                if ($DryRun) {
                    Write-Skip "Would install: $ext"
                } else {
                    & $codeCmd --install-extension $ext --force 2>&1 | Out-Null
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warn "Failed to install extension: $ext"
                    } else {
                        Write-OK $ext
                    }
                }
            }
        }
    } else {
        Write-Warn "VS Code (code) not on PATH -- skipping extensions"
    }
}

# =============================================================================
#   7. Cursor extensions
# =============================================================================
if (-not $AppsOnly) {
    Write-Step "Cursor extensions"
    $cursorCmd = "$env:LOCALAPPDATA\Programs\cursor\resources\app\bin\cursor.cmd"
    if (-not (Test-Path $cursorCmd)) { $cursorCmd = "cursor" }
    if (Get-Command $cursorCmd -ErrorAction SilentlyContinue) {
        $extFile = Join-Path $DotfilesDir "vscode\extensions.txt"
        if (Test-Path $extFile) {
            Get-Content $extFile |
            Where-Object { $_.Trim() -ne '' -and $_ -notmatch '^\s*#' } |
            ForEach-Object {
                $ext = $_.Trim()
                if ($DryRun) {
                    Write-Skip "Would install: $ext"
                } else {
                    & $cursorCmd --install-extension $ext --force 2>&1 | Out-Null
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warn "Failed to install extension: $ext"
                    } else {
                        Write-OK $ext
                    }
                }
            }
        }
    } else {
        Write-Warn "Cursor not on PATH — skipping extensions"
    }
}

# =============================================================================
#   8. Fonts
# =============================================================================
if (-not $AppsOnly) {
    Write-Step "Fonts"

    $fontsDir  = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $regPath   = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
    $checkFont = 'CaskaydiaCove Nerd Font Regular (TrueType)'

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
        $tmpZip    = "$env:TEMP\CascadiaCode.zip"
        $tmpExtract = "$env:TEMP\CascadiaCode-nf"
        $fontUrl   = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"

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
        Write-OK "Installed $count font files to $fontsDir"
    }
}

# =============================================================================
#   9. mpv config
# =============================================================================
if (-not $AppsOnly -and -not $ConfigsOnly) {
    Write-Step "mpv config"
    $mpvDir = "$HOME\workstation\tools\mpv"
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
        Write-Warn "mpv not found at $mpvDir"
        Write-Warn "  Download shinchiro build and extract to $mpvDir, then re-run install.ps1"
        Write-Warn "  Or run: irm https://raw.githubusercontent.com/hedglen/mpv-config/master/install.ps1 | iex"
    }
}

# =============================================================================
#   10. mpv — register as "Open with" for video files
# =============================================================================
if (-not $AppsOnly -and -not $ConfigsOnly) {
    Write-Step "mpv Open With registration"
    $batPath = "$HOME\workstation\tools\mpv\mpv-single.bat"
    if (-not (Test-Path $batPath)) {
        Write-Warn "mpv-single.bat not found at $batPath — skipping"
    } elseif ($DryRun) {
        Write-Skip "Would register mpv-single.bat as Open With handler for video files"
    } else {
        $appRegPath = 'HKCU:\Software\Classes\Applications\mpv-single.bat'
        New-Item -Path "$appRegPath\shell\open\command" -Force | Out-Null
        Set-ItemProperty -Path "$appRegPath\shell\open\command" -Name '(Default)' `
            -Value "cmd.exe /c `"`"$batPath`" `"%1`"`"" -Force
        Set-ItemProperty -Path $appRegPath -Name 'FriendlyAppName' -Value 'mpv (single instance)' -Force

        $exts = @('.mkv','.mp4','.avi','.mov','.wmv','.flv','.webm','.m4v','.ts','.m2ts','.mpg','.mpeg')
        foreach ($ext in $exts) {
            New-Item -Path "HKCU:\Software\Classes\$ext\OpenWithList\mpv-single.bat" -Force | Out-Null
        }
        Write-OK "mpv-single.bat registered for $($exts.Count) video extensions"
    }
}

# =============================================================================
#   11. foobar2000 theme
# =============================================================================
if (-not $AppsOnly) {
    Write-Step "foobar2000 theme"
    $fb2kScript = Join-Path $DotfilesDir "foobar2000\install-theme.ps1"
    if (Test-Path $fb2kScript) {
        & $fb2kScript -DryRun:$DryRun
    } else {
        Write-Warn "foobar2000\install-theme.ps1 not found — skipping"
    }
}

# =============================================================================
#   12. AutoHotkey — register on startup
# =============================================================================
if (-not $AppsOnly) {
    Write-Step "AutoHotkey startup"
    $ahkSrc = Join-Path $DotfilesDir "autohotkey\main.ahk"
    $ahkCmd = Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue
    $ahkExe = if ($ahkCmd) { $ahkCmd.Source } else { "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey64.exe" }
    if (Test-Path $ahkSrc) {
        if (-not (Test-Path $ahkExe)) {
            Write-Warn "AutoHotkey.exe not found at $ahkExe — skipping. Install AutoHotkey v2 and re-run."
        } else {
            $runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
            $runVal = "`"$ahkExe`" `"$ahkSrc`""
            if ($DryRun) {
                Write-Skip "Would register AHK in Run: $runVal"
            } else {
                Set-ItemProperty -Path $runKey -Name 'AutoHotkey' -Value $runVal -Force
                # Launch it now too
                if (Get-Process -Name 'AutoHotkey*' -ErrorAction SilentlyContinue) {
                    Stop-Process -Name 'AutoHotkey*' -Force -ErrorAction SilentlyContinue
                }
                Start-Process -FilePath $ahkExe -ArgumentList "`"$ahkSrc`""
                Write-OK "AutoHotkey registered for startup and launched"
            }
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
