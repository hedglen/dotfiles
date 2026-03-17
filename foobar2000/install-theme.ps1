# foobar2000 Astra Theme Installer
# Automated installation script for the Astra-inspired theme

param(
    [switch]$SkipComponents,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "   foobar2000 Astra Theme Installer" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
if ($DryRun) { Write-Host "   DRY RUN - No changes will be made" -ForegroundColor Yellow }
Write-Host ""

# Paths
$foobar2000Path = "C:\Users\rjh\foobar2000"
$foobar2000PortablePath = "$foobar2000Path\profile"
$foobar2000ConfigPath = if (Test-Path "$foobar2000Path\portable_mode_enabled") { $foobar2000PortablePath } else { "$env:APPDATA\foobar2000" }
$themePath = Join-Path $PSScriptRoot "theme"

# Check if foobar2000 is installed
Write-Host ">> Checking foobar2000 installation..." -ForegroundColor Cyan
if (-not (Test-Path $foobar2000Path)) {
    Write-Host "   !! foobar2000 not found. Installing via winget..." -ForegroundColor Yellow
    if (-not $DryRun) {
        winget install PeterPawlowski.foobar2000 --accept-package-agreements --accept-source-agreements
        Write-Host "   OK  foobar2000 installed" -ForegroundColor Green
    }
} else {
    Write-Host "   OK  foobar2000 found at $foobar2000Path" -ForegroundColor Green
}

# Required components
$components = @(
    @{
        Name = "Columns UI"
        URL = "https://www.foobar2000.org/components/view/foo_ui_columns"
        File = "foo_ui_columns.fb2k-component"
    },
    @{
        Name = "Musical Spectrum"
        URL = "https://www.foobar2000.org/components/view/foo_musical_spectrum"
        File = "foo_musical_spectrum.fb2k-component"
    },
    @{
        Name = "Waveform Seekbar"
        URL = "https://www.foobar2000.org/components/view/foo_wave_seekbar"
        File = "foo_wave_seekbar.fb2k-component"
    },
    @{
        Name = "Panel Stack Splitter"
        URL = "https://www.foobar2000.org/components/view/foo_uie_panel_splitter"
        File = "foo_uie_panel_splitter.fb2k-component"
    },
    @{
        Name = "Biography"
        URL = "https://www.foobar2000.org/components/view/foo_biography"
        File = "foo_biography.fb2k-component"
    }
)

if (-not $SkipComponents) {
    Write-Host ""
    Write-Host ">> Required Components" -ForegroundColor Cyan
    Write-Host "   The following components need to be installed manually:" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($component in $components) {
        Write-Host "   - $($component.Name)" -ForegroundColor White
        Write-Host "     Download: $($component.URL)" -ForegroundColor DarkGray
    }
    
    Write-Host ""
    Write-Host "   After downloading, install components by:" -ForegroundColor Yellow
    Write-Host "   1. Double-clicking the .fb2k-component files" -ForegroundColor DarkGray
    Write-Host "   2. Or dragging them into foobar2000" -ForegroundColor DarkGray
    Write-Host ""
    
    $response = Read-Host "   Have you installed all components? (y/n)"
    if ($response -ne 'y') {
        Write-Host "   !! Please install components first, then re-run this script" -ForegroundColor Red
        exit 1
    }
}

# Copy theme files
Write-Host ""
Write-Host ">> Installing theme files..." -ForegroundColor Cyan

if (-not (Test-Path $foobar2000ConfigPath)) {
    Write-Host "   !! Config directory not found. Run foobar2000 once first." -ForegroundColor Red
    exit 1
}

$themeDestPath = Join-Path $foobar2000ConfigPath "astra-theme"

if ($DryRun) {
    Write-Host "   -- Would copy theme files to: $themeDestPath" -ForegroundColor DarkGray
} else {
    # Create theme directory
    if (-not (Test-Path $themeDestPath)) {
        New-Item -ItemType Directory -Path $themeDestPath -Force | Out-Null
    }
    
    # Copy theme files
    Copy-Item -Path "$themePath\*" -Destination $themeDestPath -Recurse -Force
    Write-Host "   OK  Theme files copied to $themeDestPath" -ForegroundColor Green
}

# Configuration instructions
Write-Host ""
Write-Host ">> Next Steps" -ForegroundColor Cyan
Write-Host ""
Write-Host "   1. Launch foobar2000" -ForegroundColor White
Write-Host "   2. Go to: File > Preferences > Display > Default User Interface" -ForegroundColor White
Write-Host "   3. Select 'Columns UI' as the user interface" -ForegroundColor White
Write-Host "   4. Restart foobar2000" -ForegroundColor White
Write-Host "   5. Go to: File > Preferences > Display > Columns UI" -ForegroundColor White
Write-Host "   6. Click 'Import' and select the layout file from:" -ForegroundColor White
Write-Host "      $themeDestPath\astra-layout.fcl" -ForegroundColor DarkGray
Write-Host ""
Write-Host "   For visualizer settings, see:" -ForegroundColor White
Write-Host "      $themeDestPath\visualizer-settings.txt" -ForegroundColor DarkGray
Write-Host ""
Write-Host "   For equalizer preset, import:" -ForegroundColor White
Write-Host "      $themeDestPath\equalizer-preset.feq" -ForegroundColor DarkGray
Write-Host ""

Write-Host "============================================" -ForegroundColor Magenta
Write-Host "   Installation Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""
