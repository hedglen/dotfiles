-- WezTerm — primary terminal outside Cursor
-- Managed in dotfiles: wezterm/wezterm.lua → %USERPROFILE%\.wezterm.lua (see install.ps1)
-- https://wezfurlong.org/wezterm/config/lua/general.html

local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local home = wezterm.home_dir
local workstation = home .. '\\workstation'
local projects = workstation .. '\\projects'
local dotfiles = workstation .. '\\dotfiles'
local workspace_file = workstation .. '\\rjh-workspace.code-workspace'
local git_bash = 'C:\\Program Files\\Git\\bin\\bash.exe'
local system_helper_cmd = [[
$now = Get-Date
$os = Get-CimInstance Win32_OperatingSystem
$uptime = $now - $os.LastBootUpTime
$ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
  Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' } |
  Select-Object -Unique InterfaceAlias, IPAddress
$vpnAdapters = Get-NetAdapter -ErrorAction SilentlyContinue |
  Where-Object { $_.InterfaceDescription -match 'VPN|TAP|TUN|WireGuard|ProtonVPN' -or $_.Name -match 'VPN|WireGuard|ProtonVPN' } |
  Select-Object Name, Status
$drives = Get-PSDrive -PSProvider FileSystem |
  Where-Object { $_.Name -match '^[A-Z]$' } |
  Sort-Object Name

function Format-Bytes([double]$bytes) {
  if ($bytes -ge 1TB) { return ('{0:N1} TB' -f ($bytes / 1TB)) }
  if ($bytes -ge 1GB) { return ('{0:N1} GB' -f ($bytes / 1GB)) }
  return ('{0:N0} MB' -f ($bytes / 1MB))
}

Write-Host 'System Dashboard' -ForegroundColor Magenta
Write-Host ''
Write-Host (' Time:   ' + $now.ToString('yyyy-MM-dd hh:mm tt')) -ForegroundColor Cyan
Write-Host (' Uptime: ' + ('{0}d {1}h {2}m' -f $uptime.Days, $uptime.Hours, $uptime.Minutes)) -ForegroundColor Cyan
Write-Host (' Host:   ' + $env:COMPUTERNAME) -ForegroundColor Cyan
if ($vpnAdapters) {
  $activeVpn = $vpnAdapters | Where-Object Status -eq 'Up' | Select-Object -First 1
  if ($activeVpn) {
    Write-Host (' VPN:    connected (' + $activeVpn.Name + ')') -ForegroundColor Green
  } else {
    Write-Host (' VPN:    adapters found, not connected') -ForegroundColor Yellow
  }
} else {
  Write-Host (' VPN:    no VPN adapter detected') -ForegroundColor DarkGray
}

try {
  $publicIp = (& curl.exe -s --max-time 3 https://api.ipify.org).Trim()
  if ($publicIp) {
    Write-Host (' Public: ' + $publicIp) -ForegroundColor Cyan
  } else {
    Write-Host (' Public: unavailable') -ForegroundColor DarkGray
  }
} catch {
  Write-Host (' Public: unavailable') -ForegroundColor DarkGray
}

Write-Host ''

Write-Host 'Drives:' -ForegroundColor Cyan
foreach ($drive in $drives) {
  Write-Host (' ' + $drive.Name + ': ') -NoNewline -ForegroundColor White
  Write-Host ((Format-Bytes $drive.Free) + ' free') -NoNewline -ForegroundColor Green
  Write-Host (' / ' + (Format-Bytes ($drive.Used + $drive.Free)) + ' total') -ForegroundColor DarkGray
}

Write-Host ''
Write-Host 'IPv4:' -ForegroundColor Cyan
if ($ips) {
  foreach ($ip in $ips) {
    Write-Host (' ' + $ip.InterfaceAlias + ': ') -NoNewline -ForegroundColor White
    Write-Host $ip.IPAddress -ForegroundColor DarkCyan
  }
} else {
  Write-Host ' no active IPv4 addresses found' -ForegroundColor DarkGray
}

Write-Host ''
Write-Host 'Helpers:' -ForegroundColor Cyan
Write-Host ' drives       uptime       sysinfo      users        admins' -ForegroundColor DarkGray
Write-Host ' startup-list tasks-user   pkillf       reload       sync-dots' -ForegroundColor DarkGray
Write-Host ' orgmed       ytdl         trans        save-dots' -ForegroundColor DarkGray
Write-Host ''
]]
local coding_helper_cmd = [[
Set-Location 'C:\Users\rjh\workstation'
$workspace = Get-Content -LiteralPath 'C:\Users\rjh\workstation\rjh-workspace.code-workspace' -Raw | ConvertFrom-Json
$workspaceFolders = $workspace.folders | ForEach-Object {
  [PSCustomObject]@{
    Name = $_.name
    FullName = Join-Path 'C:\Users\rjh\workstation' $_.path
  }
}

Write-Host 'Coding Helper' -ForegroundColor Magenta
Write-Host ''

if (-not $workspaceFolders) {
  Write-Host 'No workspace folders found.' -ForegroundColor Yellow
} elseif ($workspaceFolders.Count -eq 1) {
  $folder = $workspaceFolders[0]
  Set-Location $folder.FullName
  Write-Host ('Opened workspace folder: ' + $folder.Name) -ForegroundColor Cyan
  if (Test-Path (Join-Path $folder.FullName '.git')) {
    Write-Host ''
    git status --short --branch
  }
} else {
  Write-Host 'Workspace folders:' -ForegroundColor Cyan
  foreach ($folder in $workspaceFolders) {
    $isRepo = Test-Path (Join-Path $folder.FullName '.git')
    $branch = if ($isRepo) { git -C $folder.FullName rev-parse --abbrev-ref HEAD 2>$null } else { '-' }
    if (-not $branch) { $branch = '?' }
    $dirty = if ($isRepo) { (git -C $folder.FullName status --porcelain 2>$null | Measure-Object).Count } else { 0 }
    $state = if (-not $isRepo) { 'folder' } elseif ($dirty -gt 0) { 'dirty' } else { 'clean' }
    $markers = @()
    if ($isRepo) { $markers += 'git' }
    if (Test-Path (Join-Path $folder.FullName 'package.json')) { $markers += 'node' }
    if (Test-Path (Join-Path $folder.FullName 'pnpm-lock.yaml')) { $markers += 'pnpm' }
    if (Test-Path (Join-Path $folder.FullName 'requirements.txt')) { $markers += 'python' }
    if (Test-Path (Join-Path $folder.FullName 'pyproject.toml')) { $markers += 'pyproject' }
    if (-not $markers) { $markers += 'folder' }

    Write-Host (' - ' + $folder.Name) -NoNewline -ForegroundColor White
    Write-Host (' [' + $branch + '] ') -NoNewline -ForegroundColor DarkGray
    Write-Host ($state + ' ') -NoNewline -ForegroundColor $(if (-not $isRepo) { 'DarkGray' } elseif ($dirty -gt 0) { 'Yellow' } else { 'Green' })
    Write-Host ('(' + ($markers -join ', ') + ')') -ForegroundColor DarkCyan
  }

  Write-Host ''
  Write-Host 'Quick jump:' -ForegroundColor Cyan
  foreach ($folder in $workspaceFolders) {
    Write-Host ('  cd .\' + $folder.Name) -ForegroundColor DarkGray
  }
}

Write-Host ''
]]
local git_live_view_cmd = [[
if command -v lazygit >/dev/null 2>&1; then
  lazygit
else
  while true; do
    clear
    printf "\033[38;5;45mRecent git activity (live, every 3s)\033[0m\n\n"
    git -c color.ui=always log --oneline --graph --decorate --all -20
    sleep 3
  done
fi
]]

local config = {}

local function pwsh_spawn(cwd, cmd)
  local spawn = { cwd = cwd }

  if cmd then
    spawn.args = { 'pwsh.exe', '-NoLogo', '-NoExit', '-Command', cmd }
  end

  return spawn
end

local function bash_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function bash_path(path)
  local drive, rest = path:match '^([A-Za-z]):\\(.*)$'

  if drive then
    return '/' .. drive:lower() .. '/' .. rest:gsub('\\', '/')
  end

  return path:gsub('\\', '/')
end

local function git_bash_spawn(cwd, cmd)
  local bash_cmd = 'cd ' .. bash_quote(bash_path(cwd))

  if cmd then
    bash_cmd = bash_cmd .. ' && ' .. cmd
  end

  return {
    cwd = cwd,
    args = { git_bash, '--login', '-i', '-c', bash_cmd .. '; exec bash -il' },
  }
end

wezterm.on('gui-startup', function(cmd)
  local startup = pwsh_spawn(home)

  if cmd and cmd.args then
    startup.args = cmd.args
  end

  local system_tab, system_pane, window = mux.spawn_window(startup)
  system_tab:set_title 'system'

  system_pane:split {
    direction = 'Right',
    size = 0.28,
    cwd = home,
    args = pwsh_spawn(home, system_helper_cmd).args,
  }

  local coding_tab, coding_pane = window:spawn_tab(pwsh_spawn(projects))
  coding_tab:set_title 'coding'
  coding_pane:split {
    direction = 'Right',
    size = 0.34,
    cwd = workstation,
    args = pwsh_spawn(workstation, coding_helper_cmd).args,
  }

  local git_tab, git_pane = window:spawn_tab(git_bash_spawn(dotfiles, 'git status --short --branch'))
  git_tab:set_title 'git'
  local git_live_pane = git_pane:split {
    direction = 'Bottom',
    size = 0.32,
    cwd = dotfiles,
    args = git_bash_spawn(dotfiles).args,
  }
  git_live_pane:send_text(git_live_view_cmd .. '\n')

  coding_tab:activate()
  window:gui_window():maximize()
end)

-- ---------------------------------------------------------------------------
-- Shell (PowerShell 7): same profile as Windows Terminal / Cursor integrated
-- ---------------------------------------------------------------------------
config.default_prog = { 'pwsh.exe', '-NoLogo' }
config.default_cwd = home

-- ---------------------------------------------------------------------------
-- Appearance — matches dotfiles windows-terminal "Neon Dark" + Oh My Posh
-- ---------------------------------------------------------------------------
config.color_schemes = {
  ['Neon Dark (hedg)'] = {
    foreground = '#E4E4E4',
    background = '#0E0E0E',
    cursor_fg = '#0E0E0E',
    cursor_bg = '#FF66EE',
    cursor_border = '#FF66EE',
    selection_fg = '#E4E4E4',
    selection_bg = '#3D2560',
    ansi = {
      '#252525',
      '#FF6B8A',
      '#00E8B5',
      '#FFD447',
      '#64B5FF',
      '#E954FF',
      '#00E8FF',
      '#C8C8D0',
    },
    brights = {
      '#4A4A55',
      '#FF99AA',
      '#5CFFB8',
      '#FFE566',
      '#A8D4FF',
      '#F4A4FF',
      '#66F9FF',
      '#FFFFFF',
    },
  },
}
config.color_scheme = 'Neon Dark (hedg)'

config.font = wezterm.font_with_fallback {
  'JetBrainsMono Nerd Font',
  'CaskaydiaCove Nerd Font',
  'Consolas',
}
config.font_size = 12.5
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.window_background_opacity = 1.0
config.text_background_opacity = 1.0
config.window_decorations = 'TITLE | RESIZE'
config.integrated_title_button_style = 'Windows'

config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

config.scrollback_lines = 100000
config.enable_scroll_bar = false

config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.85 }

config.initial_cols = 140
config.initial_rows = 35

config.window_padding = {
  left = 10,
  right = 10,
  top = 8,
  bottom = 8,
}

-- ---------------------------------------------------------------------------
-- Tabs
-- ---------------------------------------------------------------------------
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- ---------------------------------------------------------------------------
-- Quick launch (Ctrl+Shift+P) — spawn new tab in common roots
-- ---------------------------------------------------------------------------
config.launch_menu = {
  {
    label = 'pwsh — home',
    args = { 'pwsh.exe', '-NoLogo' },
    cwd = home,
  },
  {
    label = 'pwsh — workstation',
    args = { 'pwsh.exe', '-NoLogo' },
    cwd = workstation,
  },
  {
    label = 'pwsh — dotfiles',
    args = { 'pwsh.exe', '-NoLogo' },
    cwd = dotfiles,
  },
  {
    label = 'pwsh — projects',
    args = { 'pwsh.exe', '-NoLogo' },
    cwd = projects,
  },
  {
    label = 'pwsh — scripts',
    args = { 'pwsh.exe', '-NoLogo' },
    cwd = workstation .. '\\scripts',
  },
}

-- ---------------------------------------------------------------------------
-- Keys
-- ---------------------------------------------------------------------------
config.keys = {
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ShowLauncherArgs { flags = 'FUZZY|LAUNCH_MENU_ITEMS' } },
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'f', mods = 'CTRL|SHIFT', action = act.Search { CaseInSensitiveString = '' } },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.ClearScrollback 'ScrollbackOnly' },
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = '1', mods = 'ALT', action = act.ActivateTab(0) },
  { key = '2', mods = 'ALT', action = act.ActivateTab(1) },
  { key = '3', mods = 'ALT', action = act.ActivateTab(2) },
  { key = '4', mods = 'ALT', action = act.ActivateTab(3) },
  { key = '5', mods = 'ALT', action = act.ActivateTab(4) },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = '\\', mods = 'ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'ALT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'z', mods = 'ALT', action = act.TogglePaneZoomState },
  { key = 'LeftArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'RightArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Up', 2 } },
  { key = 'DownArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Down', 2 } },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = true } },
  { key = 'x', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = true } },
}

-- ---------------------------------------------------------------------------
-- Mouse — right-click: paste (or copy+clear selection, like Windows Terminal)
-- ---------------------------------------------------------------------------
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and sel ~= '' then
        window:perform_action(act.CopyTo 'Clipboard', pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.PasteFrom 'Clipboard', pane)
      end
    end),
  },
}

return config
