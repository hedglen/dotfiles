# =============================================================================
#   scimitar-lib.ps1
#   XML parsing helpers for Scimitar profile diffing.
#   Dot-sourced by scimitar.ps1 — not invoked directly.
# =============================================================================

# Returns a hashtable of { ButtonId -> KeyName } from a hw profile XML file.
# ButtonId: e.g. "MouseG1", KeyName: e.g. "F13" or the polymorphic action type.
function Get-ButtonBindings {
    param([string]$FilePath)

    $bindings = [ordered]@{}
    if (-not (Test-Path $FilePath)) { return $bindings }

    $xml = [xml](Get-Content $FilePath -Encoding UTF8)

    # Each binding: parent has <first> (action) and <second> (button id + layer)
    $nodes = $xml.SelectNodes("//second[starts-with(key, 'Mouse')]")
    foreach ($node in $nodes) {
        $btn    = $node.key
        $first  = $node.ParentNode.first
        # KeyRemapAction has <keyName>; other action types have <polymorphic_name>
        $label  = if ($first.keyName)         { $first.keyName }
                  elseif ($first.polymorphic_name) { $first.polymorphic_name }
                  else                         { '?' }
        $bindings[$btn] = $label
    }
    return $bindings
}

# Returns a hashtable of device settings from config.cuecfg.
function Get-DeviceSettings {
    param([string]$FilePath)

    $settings = [ordered]@{}
    if (-not (Test-Path $FilePath)) { return $settings }

    $xml = [xml](Get-Content $FilePath -Encoding UTF8)

    $keys = @(
        'ActiveHardwareProfileIndex',
        'AngleSnappingEnabled',
        'AngleSnappingAngle',
        'BrightnessLevel',
        'LiftHeightLevel',
        'SleepModeEnabled',
        'SleepModeWaitDelaySec'
    )
    foreach ($k in $keys) {
        $node = $xml.SelectSingleNode("//value[@name='$k']")
        $settings[$k] = if ($node) { $node.'#text' } else { $null }
    }
    return $settings
}

# Returns the profile <name> from a hw-slot .cueprofiledata file.
function Get-ProfileName {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) { return $null }
    $xml = [xml](Get-Content $FilePath -Encoding UTF8)
    return $xml.cereal.profile.name
}

# Returns a rough lighting fingerprint (char count of the lighting sections).
# Used only to detect whether lighting changed — not to describe what changed.
function Get-LightingFingerprint {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) { return 0 }
    $xml = [xml](Get-Content $FilePath -Encoding UTF8)
    $nodes = $xml.SelectNodes("//*[contains(local-name(), 'LightingsProperty')]")
    $combined = ($nodes | ForEach-Object { $_.OuterXml }) -join ''
    return $combined.Length
}

# Prints a human-readable diff between two sets of backup files.
# $FromDir and $ToDir are paths to folders containing the backup files,
# or $null to use the live iCUE source paths.
function Show-ProfileDiff {
    param(
        [string]$FromDir,
        [string]$ToDir,
        [string]$FromLabel = 'before',
        [string]$ToLabel   = 'after'
    )

    $slots = @('hw-slot-1', 'hw-slot-2', 'hw-slot-3')

    Write-Host ""
    Write-Host "=== Scimitar Profile Diff: $FromLabel -> $ToLabel ===" -ForegroundColor Cyan

    foreach ($slot in $slots) {
        $fromFile = Join-Path $FromDir "$slot.cueprofiledata"
        $toFile   = Join-Path $ToDir   "$slot.cueprofiledata"

        if (-not (Test-Path $fromFile) -and -not (Test-Path $toFile)) { continue }

        $fromName = Get-ProfileName $fromFile
        $toName   = Get-ProfileName $toFile
        $nameStr  = if ($fromName -eq $toName) { $fromName } else { "$fromName -> $toName" }

        Write-Host ""
        Write-Host "  $slot ($nameStr)" -ForegroundColor White

        $fromB = Get-ButtonBindings $fromFile
        $toB   = Get-ButtonBindings $toFile

        $allBtns = ($fromB.Keys + $toB.Keys | Select-Object -Unique | Sort-Object)
        $anyChange = $false
        foreach ($btn in $allBtns) {
            $f = $fromB[$btn]
            $t = $toB[$btn]
            if ($f -ne $t) {
                $anyChange = $true
                $old = if ($f) { $f } else { '(none)' }
                $new = if ($t) { $t } else { '(none)' }
                Write-Host ("    {0,-12} {1} -> {2}" -f "$btn`:", $old, $new) -ForegroundColor Yellow
            }
        }
        if (-not $anyChange) {
            Write-Host "    Bindings: unchanged" -ForegroundColor DarkGray
        }

        $fromFp = Get-LightingFingerprint $fromFile
        $toFp   = Get-LightingFingerprint $toFile
        $lightStr = if ($fromFp -eq $toFp) { 'unchanged' } else { 'changed' }
        $lightColor = if ($fromFp -eq $toFp) { 'DarkGray' } else { 'Yellow' }
        Write-Host "    Lighting: $lightStr" -ForegroundColor $lightColor
    }

    # Device settings diff from config.cuecfg
    $fromCfg = Join-Path $FromDir 'config.cuecfg'
    $toCfg   = Join-Path $ToDir   'config.cuecfg'
    if ((Test-Path $fromCfg) -or (Test-Path $toCfg)) {
        Write-Host ""
        Write-Host "  Device settings" -ForegroundColor White
        $fromS = Get-DeviceSettings $fromCfg
        $toS   = Get-DeviceSettings $toCfg
        $anyChange = $false
        foreach ($k in $fromS.Keys) {
            $f = $fromS[$k]; $t = $toS[$k]
            if ($f -ne $t) {
                $anyChange = $true
                Write-Host ("    {0,-36} {1} -> {2}" -f "$k`:", $f, $t) -ForegroundColor Yellow
            }
        }
        if (-not $anyChange) {
            Write-Host "    All unchanged" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
}
