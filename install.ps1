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
#     -NoApps    Skip winget import and Scoop installs
#     -NoScoop   Skip Scoop only (winget import still runs)
#     -NoPythonProjects  Skip venv setup for projects\media-organizer and projects\ytdl
#     -DryRun    Preview what would happen without doing anything
#
#   Scoop: if missing, get.scoop.sh is run automatically, then packages from apps\scoop-packages.json.
# =============================================================================

param(
    [switch]$AppsOnly,
    [switch]$ConfigsOnly,
    [switch]$NoApps,
    [switch]$NoScoop,
    [switch]$NoPythonProjects,
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

function Install-DotfilesPythonProject {
    param(
        [Parameter(Mandatory)]
        [string] $RelativePath,
        [Parameter(Mandatory)]
        [string[]] $PipArgs,
        [switch] $DryRun
    )
    $proj = Join-Path $DotfilesDir $RelativePath
    if (-not (Test-Path $proj)) {
        Write-Warn "Project not found — $RelativePath"
        return
    }
    $py = Get-Command py -ErrorAction SilentlyContinue
    if (-not $py) {
        Write-Warn "Python launcher (py) not on PATH — skip venv for $RelativePath"
        return
    }
    $venvPy = Join-Path $proj ".venv\Scripts\python.exe"
    if ($DryRun) {
        if (Test-Path $venvPy) {
            Write-Skip "Would pip install in $RelativePath (venv exists)"
        } else {
            Write-Skip "Would create .venv and pip install in $RelativePath"
        }
        return
    }
    Push-Location $proj
    try {
        if (-not (Test-Path $venvPy)) {
            & py -3 -m venv .venv
            if ($LASTEXITCODE -ne 0) {
                Write-Warn "python -m venv failed in $RelativePath"
                return
            }
        }
        $pip = Join-Path $proj ".venv\Scripts\pip.exe"
        if (-not (Test-Path $pip)) {
            Write-Warn "pip not found under $RelativePath\.venv"
            return
        }
        $prevEA = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $pip install --upgrade pip 2>$null | Out-Null
        & $pip install @PipArgs
        $exit = $LASTEXITCODE
        $ErrorActionPreference = $prevEA
        if ($exit -eq 0) {
            Write-OK "Python venv: $RelativePath"
        } else {
            Write-Warn "pip install exited $exit for $RelativePath"
        }
    } finally {
        Pop-Location
    }
}

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
        @{ url = "https://github.com/hedglen/hedglen.git";  dst = "$HOME\workstation\hedglen-profile" }
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

    # Python helpers (media-organizer, ytdl) ship under dotfiles\projects\
    Write-Step "Projects (dotfiles\projects)"
    $projectsBundled = Join-Path $DotfilesDir "projects"
    if (Test-Path $projectsBundled) {
        Write-OK "projects directory present in dotfiles"
    } elseif ($DryRun) {
        Write-Skip "Would create: $projectsBundled"
    } else {
        New-Item -ItemType Directory -Path $projectsBundled -Force | Out-Null
        Write-Warn "Created empty projects\ — git pull dotfiles for media-organizer / ytdl"
    }

    $legacyProjects = "$HOME\workstation\projects"
    if (Test-Path $legacyProjects) {
        try {
            $item = Get-Item -LiteralPath $legacyProjects -ErrorAction Stop
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                Write-Skip "workstation\projects already present (junction or symlink)"
            } else {
                Write-Skip "workstation\projects exists as a normal folder — not replaced (merge into dotfiles\projects if needed)"
            }
        } catch {
            Write-Warn "Could not inspect workstation\projects: $_"
        }
    } elseif ($DryRun) {
        Write-Skip "Would create junction: $legacyProjects → $projectsBundled"
    } else {
        try {
            New-Item -ItemType Junction -Path $legacyProjects -Target $projectsBundled | Out-Null
            Write-OK "junction workstation\projects → dotfiles\projects"
        } catch {
            Write-Warn "Could not create junction at $legacyProjects — $_"
        }
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

    # Utility scripts ship inside this repo (not a separate clone).
    Write-Step "Utility scripts (dotfiles\scripts)"
    $scriptsDir = Join-Path $DotfilesDir "scripts"
    if (Test-Path $scriptsDir) {
        Write-OK "scripts directory present"
    } elseif ($DryRun) {
        Write-Skip "Would create: $scriptsDir"
    } else {
        New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
        Write-Warn "Created empty scripts\ — git pull dotfiles for the full script tree"
    }

    # Legacy path: many docs/tools still say $HOME\workstation\scripts
    $legacyScripts = "$HOME\workstation\scripts"
    if (Test-Path $legacyScripts) {
        try {
            $item = Get-Item -LiteralPath $legacyScripts -ErrorAction Stop
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                Write-Skip "workstation\scripts already present (junction or symlink)"
            } else {
                Write-Skip "workstation\scripts exists as a normal folder — not replaced (merge into dotfiles\scripts if needed)"
            }
        } catch {
            Write-Warn "Could not inspect workstation\scripts: $_"
        }
    } elseif ($DryRun) {
        Write-Skip "Would create junction: $legacyScripts → $scriptsDir"
    } else {
        try {
            New-Item -ItemType Junction -Path $legacyScripts -Target $scriptsDir | Out-Null
            Write-OK "junction workstation\scripts → dotfiles\scripts"
        } catch {
            Write-Warn "Could not create junction at $legacyScripts — $_"
        }
    }
}

# =============================================================================
#   3. Install apps (single source: this repo only — no %USERPROFILE%\Documents copies)
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
                Write-OK "winget import finished"
            } catch {
                Write-Warn "winget import finished with errors (some packages may have failed) — $_"
            }
        }
    } else {
        Write-Warn "apps\winget-packages.json not found — skipping"
    }

    Write-Step "Installing Scoop CLI packages"

    $scoopFile = Join-Path $DotfilesDir "apps\scoop-packages.json"
    if ($NoScoop) {
        Write-Skip "Skipping Scoop (-NoScoop)"
    } elseif (-not (Test-Path $scoopFile)) {
        Write-Warn "apps\scoop-packages.json not found — skipping Scoop"
    } else {
        $haveScoop = [bool](Get-Command scoop -ErrorAction SilentlyContinue)
        if (-not $haveScoop) {
            if ($DryRun) {
                Write-Skip "Would install Scoop (get.scoop.sh) then scoop install …"
            } else {
                Write-Step "Bootstrapping Scoop (not on PATH)"
                try {
                    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
                    $prevEA = $ErrorActionPreference
                    $ErrorActionPreference = 'Continue'
                    Invoke-Expression (Invoke-RestMethod -Uri https://get.scoop.sh -UseBasicParsing)
                    $ErrorActionPreference = $prevEA
                    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                        [System.Environment]::GetEnvironmentVariable('Path', 'User')
                    $haveScoop = [bool](Get-Command scoop -ErrorAction SilentlyContinue)
                    if ($haveScoop) {
                        Write-OK "Scoop installed"
                    } else {
                        Write-Warn "Scoop bootstrap finished but scoop is still not on PATH — open a new terminal or add shims to PATH"
                    }
                } catch {
                    Write-Warn "Scoop bootstrap failed — $_"
                }
            }
        }

        if (-not $haveScoop -and -not $DryRun) {
            Write-Warn "Scoop not on PATH — skipping apps\scoop-packages.json"
        } elseif ($DryRun -and $haveScoop) {
            Write-Skip "Would run: scoop install <names from apps\scoop-packages.json>"
        } elseif (-not $DryRun -and $haveScoop) {
            $names = @((Get-Content $scoopFile -Raw | ConvertFrom-Json).packages | Where-Object { $_ })
            if ($names.Count -eq 0) {
                Write-Skip "No package names in scoop-packages.json"
            } else {
                $prevEA = $ErrorActionPreference
                $ErrorActionPreference = 'Continue'
                & scoop install @names
                $exit = $LASTEXITCODE
                $ErrorActionPreference = $prevEA
                if ($exit -eq 0) {
                    Write-OK "Scoop install ($($names.Count) packages)"
                } else {
                    Write-Warn "scoop install exited $exit (some apps may already be installed)"
                }
            }
        }
    }
}

# Python helpers: run even with -NoApps (ConfigsOnly skips everything substantive)
if (-not $ConfigsOnly -and -not $NoPythonProjects) {
    Write-Step "Python venvs (media-organizer, ytdl)"
    Install-DotfilesPythonProject -RelativePath "projects\media-organizer" -PipArgs @("-r", "requirements.txt") -DryRun:$DryRun
    Install-DotfilesPythonProject -RelativePath "projects\ytdl" -PipArgs @("rich") -DryRun:$DryRun
} elseif ($ConfigsOnly) {
    Write-Skip "Skipping Python project venvs (-ConfigsOnly)"
} else {
    Write-Skip "Skipping Python project venvs (-NoPythonProjects)"
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
            src  = "projects\ytdl\appdata-config"
            dst  = "$env:APPDATA\yt-dlp\config"
            desc = "yt-dlp global config (from projects/ytdl)"
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

        # Skip if symlink already points to the right place (full paths; Target may be string[])
        if (Test-Path -LiteralPath $dst -ErrorAction SilentlyContinue) {
            $linkItem = Get-Item -LiteralPath $dst -Force -ErrorAction SilentlyContinue
            if ($linkItem -and $linkItem.LinkType -eq 'SymbolicLink') {
                $t = $linkItem.Target
                if ($t -is [System.Array]) { $t = $t[0] }
                try {
                    if ([IO.Path]::GetFullPath($t) -eq [IO.Path]::GetFullPath($src)) {
                        Write-Skip "$($c.desc) already linked"
                        continue
                    }
                } catch { }
            }
        }

        # Ensure destination directory exists (-Force is idempotent; creates full path)
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null

        # Wrong symlink: remove (Copy-Item on links often fails). Plain file/dir: back up then remove.
        $existing = Get-Item -LiteralPath $dst -Force -ErrorAction SilentlyContinue
        if ($existing) {
            if ($existing.LinkType -eq 'SymbolicLink') {
                Remove-Item -LiteralPath $dst -Force
            } elseif ($existing.PSIsContainer) {
                $backup = "$dst.backup"
                Copy-Item -LiteralPath $dst -Destination $backup -Recurse -Force
                Remove-Item -LiteralPath $dst -Recurse -Force
                Write-Host "   Backed up existing to $backup" -ForegroundColor DarkGray
            } else {
                $backup = "$dst.backup"
                Copy-Item -LiteralPath $dst -Destination $backup -Force
                Remove-Item -LiteralPath $dst -Force
                Write-Host "   Backed up existing to $backup" -ForegroundColor DarkGray
            }
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
                    $installOut = & $codeCmd --install-extension $ext --force 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warn "Failed to install extension: $ext"
                        $installOut | ForEach-Object { Write-Warn "  $_" }
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
                    $installOut = & $cursorCmd --install-extension $ext --force 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warn "Failed to install extension: $ext"
                        $installOut | ForEach-Object { Write-Warn "  $_" }
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
#   9. mpv config — junction tools\mpv\portable_config → dotfiles\mpv-config
# =============================================================================
if (-not $AppsOnly -and -not $ConfigsOnly) {
    Write-Step "mpv config"
    $mpvDir          = Join-Path $HOME "workstation\tools\mpv"
    $mpvConfigSrc    = Join-Path $DotfilesDir "mpv-config"
    $portableConfig  = Join-Path $mpvDir "portable_config"
    $mpvConfigSrcFull = [System.IO.Path]::GetFullPath($mpvConfigSrc)

    if (-not (Test-Path -LiteralPath $mpvConfigSrc)) {
        Write-Warn "mpv config bundle missing: $mpvConfigSrc (expected with dotfiles checkout)"
    } elseif (-not (Test-Path -LiteralPath $mpvDir)) {
        Write-Warn "mpv not found at $mpvDir"
        Write-Warn "  Download shinchiro build and extract to $mpvDir, then re-run install.ps1"
        Write-Warn "  Or run: .\mpv-config\install.ps1 from your dotfiles checkout"
    } else {
        $alreadyOk = $false
        if (Test-Path -LiteralPath $portableConfig) {
            $item = Get-Item -LiteralPath $portableConfig -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                $tgt = $item.Target
                if ($tgt -is [array] -and $tgt.Count -gt 0) { $tgt = $tgt[0] }
                $got = [System.IO.Path]::GetFullPath($tgt.TrimEnd('\', '/'))
                if ($got -ieq $mpvConfigSrcFull) {
                    Write-Skip "mpv portable_config already linked → $mpvConfigSrc"
                    $alreadyOk = $true
                }
            }
        }

        if (-not $alreadyOk) {
            if ($DryRun) {
                if (Test-Path -LiteralPath $portableConfig) {
                    Write-Skip "Would replace $portableConfig with junction → $mpvConfigSrcFull"
                } else {
                    Write-Skip "Would create junction: $portableConfig → $mpvConfigSrcFull"
                }
            } else {
                if (Test-Path -LiteralPath $portableConfig) {
                    $item = Get-Item -LiteralPath $portableConfig -Force
                    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                        Remove-Item -LiteralPath $portableConfig -Force
                    } else {
                        $bak = "$portableConfig.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
                        Move-Item -LiteralPath $portableConfig -Destination $bak
                        Write-Host "   Backed up existing portable_config to $bak" -ForegroundColor DarkGray
                    }
                }
                try {
                    New-Item -ItemType Junction -Path $portableConfig -Target $mpvConfigSrcFull -Force | Out-Null
                    Write-OK "mpv portable_config → dotfiles\mpv-config"
                } catch {
                    Write-Warn "Could not create junction at $portableConfig — $_"
                }
            }
        }
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
    if (Test-Path $ahkSrc) {
        $ahkSrc = (Resolve-Path $ahkSrc).Path
    }
    # Prefer a real AutoHotkey64.exe. WindowsApps\AutoHotkey.exe is an app-alias shim that runs
    # launcher.ahk and often throws "cannot find path" on FileRead(ScriptPath) at startup.
    $ahkCandidates = @(
        "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey64.exe",
        "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:LOCALAPPDATA\Programs\AutoHotkey\AutoHotkey64.exe"
    )
    $ahkExe = $ahkCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $ahkExe) {
        $ahkCmd = Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue
        if ($ahkCmd -and $ahkCmd.Source -notmatch '\\WindowsApps\\') {
            $ahkExe = $ahkCmd.Source
        }
    }
    if (-not $ahkExe) {
        $ahkExe = "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey64.exe"
    }
    if (Test-Path $ahkSrc) {
        if (-not (Test-Path $ahkExe)) {
            Write-Warn "AutoHotkey.exe not found at $ahkExe — skipping. Install AutoHotkey v2 and re-run."
        } else {
            $runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
            $runVal = "`"$ahkExe`" `"$ahkSrc`""
            $currentRun = (Get-ItemProperty -Path $runKey -Name 'AutoHotkey' -ErrorAction SilentlyContinue).AutoHotkey
            if ($DryRun) {
                if ($currentRun -and $currentRun -ne $runVal) {
                    Write-Skip "Would repair stale AHK Run entry:"
                    Write-Skip "   old: $currentRun"
                }
                Write-Skip "Would register AHK in Run: $runVal"
            } else {
                if ($currentRun -and $currentRun -ne $runVal) {
                    Write-Warn "Repairing stale AHK Run entry:"
                    Write-Warn "   old: $currentRun"
                }
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
