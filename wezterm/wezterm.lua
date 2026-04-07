-- WezTerm — primary terminal outside Cursor
-- Managed in dotfiles: wezterm/wezterm.lua → %USERPROFILE%\.wezterm.lua (see install.ps1)
-- https://wezfurlong.org/wezterm/config/lua/general.html

local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local home = wezterm.home_dir
local workstation = home .. '\\workstation'
local dotfiles = workstation .. '\\dotfiles'
local projects = dotfiles .. '\\projects'
local git_bash = 'C:\\Program Files\\Git\\bin\\bash.exe'
local function detect_wsl_distro()
  local preferred = { 'Ubuntu', 'Ubuntu-24.04', 'Ubuntu-22.04' }
  local ok, handle = pcall(io.popen, 'wsl.exe -l -q 2>NUL')
  if not ok or not handle then
    return 'Ubuntu'
  end
  local raw = handle:read('*a') or ''
  handle:close()
  local found = {}
  for line in raw:gmatch('[^\r\n]+') do
    local name = line:gsub('^%s+', ''):gsub('%s+$', '')
    if name ~= '' then
      found[name:lower()] = name
    end
  end
  for _, name in ipairs(preferred) do
    local match = found[name:lower()]
    if match then
      return match
    end
  end
  for _, name in pairs(found) do
    return name
  end
  return 'Ubuntu'
end
local wsl_distro = detect_wsl_distro()
local system_helper_cmd = [[
Clear-Host
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
Write-Host 'Updates & Upgrades' -ForegroundColor Magenta
Write-Host ' Run order (recommended):' -ForegroundColor Cyan
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'dots-health' -NoNewline -ForegroundColor Yellow; Write-Host '  precheck layout + key tools' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'dots-update -DryRun' -NoNewline -ForegroundColor Yellow; Write-Host '  preview dotfiles/apps actions' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'Start ms-settings:windowsupdate' -NoNewline -ForegroundColor Yellow; Write-Host '  apply Windows updates first' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'dots-update' -NoNewline -ForegroundColor Yellow; Write-Host '  primary full update run' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'pip-upgrade' -NoNewline -ForegroundColor Yellow; Write-Host '  media-organizer venv pip upgrade' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'py-media-deps' -NoNewline -ForegroundColor Yellow; Write-Host '  media-organizer deps' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'py-ytdl-deps' -NoNewline -ForegroundColor Yellow; Write-Host '  ytdl helper deps' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'py-transcribe-deps' -NoNewline -ForegroundColor Yellow; Write-Host '  transcribe env package' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'py-refresh-venvs' -NoNewline -ForegroundColor Yellow; Write-Host '  rerun install -NoApps when needed' -ForegroundColor DarkGray
Write-Host ''
Write-Host ' Manual package manager path (optional):' -ForegroundColor Cyan
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'winget source update' -NoNewline -ForegroundColor Yellow; Write-Host '  refresh package sources' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'winget list --upgrade-available' -NoNewline -ForegroundColor Yellow; Write-Host '  list pending upgrades' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'scoop status' -NoNewline -ForegroundColor Yellow; Write-Host '  list outdated buckets/apps' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'winget upgrade --all' -NoNewline -ForegroundColor Yellow; Write-Host '  upgrade all winget apps' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'winget upgrade --id <PackageId>' -NoNewline -ForegroundColor Yellow; Write-Host '  upgrade one package' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'scoop update scoop' -NoNewline -ForegroundColor Yellow; Write-Host '  update scoop itself' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'scoop update *' -NoNewline -ForegroundColor Yellow; Write-Host '  update all scoop apps' -ForegroundColor DarkGray
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'scoop cleanup *' -NoNewline -ForegroundColor Yellow; Write-Host '  remove old versions' -ForegroundColor DarkGray
Write-Host ''
Write-Host '  ' -NoNewline -ForegroundColor Yellow; Write-Host 'usoclient StartScan' -NoNewline -ForegroundColor Yellow; Write-Host '  trigger scan (may be policy-limited)' -ForegroundColor DarkGray
Write-Host ''
]]
local coding_helper_cmd = [[
Clear-Host
& {
  function _cliRow($cmd, $desc) {
    Write-Host '  ' -NoNewline
    Write-Host $cmd -NoNewline -ForegroundColor Yellow
    Write-Host ('  ' + $desc) -ForegroundColor DarkGray
  }
  Write-Host 'Coding - CLI quick reference' -ForegroundColor Magenta
  Write-Host 'Most tools from Scoop. Git tab for repo status; System tab for drives and pwsh helpers.' -ForegroundColor DarkGray
  Write-Host ''

  Write-Host 'Listing' -ForegroundColor Cyan
  _cliRow 'll / la' 'Get-ChildItem (pwsh profile aliases)'
  _cliRow 'eza -la' 'colorized long listing'
  _cliRow 'eza -la --git' 'git column when cwd is inside one repo'
  Write-Host ''

  Write-Host 'Find and pick' -ForegroundColor Cyan
  _cliRow 'rg pattern' 'ripgrep: search file contents'
  _cliRow 'rg -l pattern' 'only filenames with matches'
  _cliRow 'fd name' 'find files by path pattern (respects .gitignore)'
  _cliRow 'fzf' 'fuzzy picker; pipe lines in (e.g. fd | fzf)'
  Write-Host ''

  Write-Host 'View and diffs' -ForegroundColor Cyan
  _cliRow 'bat file' 'syntax-highlighted file view'
  _cliRow 'less file' 'plain pager'
  _cliRow 'git diff' 'uses delta if set in gitconfig pager / diff filter'
  Write-Host ''

  Write-Host 'Data' -ForegroundColor Cyan
  _cliRow 'jq' 'query JSON (.key, map, select; stdin = JSON text)'
  Write-Host ''

  Write-Host 'Navigate' -ForegroundColor Cyan
  _cliRow 'z / zi' 'zoxide jump (zi = interactive); pwsh and bash'
  Write-Host ''

  Write-Host 'Git and GitHub' -ForegroundColor Cyan
  _cliRow 'lazygit' 'full-screen git TUI'
  _cliRow 'gh' 'GitHub CLI (pr, issue, repo; gh auth login once)'
  _cliRow 'git status -sb' 'short branch + change list'
  Write-Host ''

  Write-Host 'PowerShell profile' -ForegroundColor Cyan
  _cliRow 'reload' 're-source profile.ps1'
  _cliRow 'which name' 'resolve a command to its path'
  _cliRow 'grep pat' 'pipeline: ... | grep pat (Select-String)'
  _cliRow 'touch path' 'create empty file'
  _cliRow 'dots / tools / home' 'cd shortcuts (see profile.ps1)'
  Write-Host ''

  Write-Host 'Docs: dotfiles/docs/workstation-tools.md (full tool map)' -ForegroundColor DarkCyan
  Write-Host ''
}
]]
local git_top_helper_cmd = [[__wt_repo="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; printf "%s\n" "$__wt_repo" > ~/.wezterm-git-current-repo; export PROMPT_COMMAND='__wt_repo="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; printf "%s\n" "$__wt_repo" > ~/.wezterm-git-current-repo'; git status --short --branch; exec bash -il]]
-- Git tab right pane: workspace clean/dirty + git cheat sheet; refreshes every 10s.
local git_right_panel_cmd = [[
while ($true) {
  Clear-Host
  Set-Location "$env:USERPROFILE\workstation"
  $wsFile = Get-ChildItem -LiteralPath "$env:USERPROFILE\workstation" -Filter "*.code-workspace" -ErrorAction SilentlyContinue | Select-Object -First 1
  $workspace = if ($wsFile) { Get-Content -LiteralPath $wsFile.FullName -Raw | ConvertFrom-Json } else { $null }
  $workspaceFolders = if ($workspace) { $workspace.folders | ForEach-Object {
    [PSCustomObject]@{
      Name = $_.name
      FullName = Join-Path "$env:USERPROFILE\workstation" $_.path
    }
  } } else { @() }

  Write-Host 'Workspace folders:' -ForegroundColor Cyan
  if (-not $workspaceFolders) {
    Write-Host ' No workspace file or folders.' -ForegroundColor Yellow
  } else {
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
  }

  Write-Host ''
  Write-Host 'Git — Commit & Push' -ForegroundColor Magenta
  Write-Host ''
  Write-Host '  1.  git status --short --branch' -ForegroundColor Yellow
  Write-Host '      see what changed and what branch you are on' -ForegroundColor DarkGray
  Write-Host ''
  Write-Host '  2.  git diff' -ForegroundColor Yellow
  Write-Host '      review unstaged changes' -ForegroundColor DarkGray
  Write-Host ''
  Write-Host '  3.  git add <file>' -ForegroundColor Yellow
  Write-Host '      or: git add -A  to stage everything' -ForegroundColor DarkGray
  Write-Host ''
  Write-Host '  4.  git diff --staged' -ForegroundColor Yellow
  Write-Host '      confirm what is about to be committed' -ForegroundColor DarkGray
  Write-Host ''
  Write-Host '  5.  git commit -m "type: description"' -ForegroundColor Yellow
  Write-Host '      feat  fix  docs  chore  refactor  style' -ForegroundColor DarkGray
  Write-Host ''
  Write-Host '  6.  git push' -ForegroundColor Yellow
  Write-Host '      new branch: git push -u origin HEAD' -ForegroundColor DarkGray
  Write-Host ''
  Write-Host 'Undo:' -ForegroundColor Cyan
  Write-Host '  unstage   git restore --staged <file>'
  Write-Host '  discard   git restore <file>'
  Write-Host '  park      git stash push -m "note"'
  Write-Host '  unpause   git stash pop'
  Write-Host ''
  Write-Host 'Workspace + cheat refresh every 10s. Ctrl+C to stop.' -ForegroundColor DarkGray
  Start-Sleep -Seconds 10
}
]]
local git_live_view_cmd = [[
state_file="$HOME/.wezterm-git-current-repo"
default_repo="$HOME/workstation/dotfiles"

while true; do
  clear
  repo="$default_repo"
  if [ -f "$state_file" ]; then
    candidate="$(tr -d '\r' < "$state_file" 2>/dev/null)"
    if [ -n "$candidate" ]; then
      repo="$candidate"
    fi
  fi

  if git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch="$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    repo_name="$(basename "$repo")"
    printf "\033[38;5;45mGit Watch\033[0m  %s [%s]\n\n" "$repo_name" "$branch"
    printf "\033[38;5;81mLegend:\033[0m * commit | / \\ branch/merge lines | (...) refs | M modified | A added | ?? untracked\n\n"
    printf "\033[38;5;81mStatus:\033[0m\n"
    git -C "$repo" status --short --branch
    printf "\n\033[38;5;81mRecent history:\033[0m\n"
    git -C "$repo" -c color.ui=always log --oneline --graph --decorate --all -20
  else
    printf "\033[38;5;45mGit Watch\033[0m\n\n"
    printf "Waiting for a git repo in the top pane.\n"
    printf "Current path: %s\n" "$repo"
  fi

  printf "\n\033[38;5;244mRefreshes every 3s. Change repo in the top pane with cd.\033[0m\n"
  sleep 3
done
]]
local wsl_helper_cmd = [[
cd "$HOME" || exit 1
clear
_win_ws=$(wslpath "$(powershell.exe -NoProfile -Command '$env:USERPROFILE' 2>/dev/null | tr -d '\r')")/workstation
_win_projects="${_win_ws}/dotfiles/projects"
_win_dotfiles="${_win_ws}/dotfiles"
_win_scripts="${_win_ws}/dotfiles/scripts"
 printf "\033[35mWSL Helper\033[0m\n\n"
 printf "\033[36mDistro:\033[0m  %s\n" "${WSL_DISTRO_NAME:-Ubuntu}"
 printf "\033[36mKernel:\033[0m  %s\n" "$(uname -r)"
 printf "\033[36mShell:\033[0m   %s\n" "$(command -v zsh)"
 printf "\033[36mHome:\033[0m    %s\n" "$HOME"
 printf "\033[36mMount:\033[0m   %s\n" "$_win_ws"
 printf "\n\033[36mQuick jump:\033[0m\n"
 printf "  cd ~\n"
 printf "  cd %s\n" "$_win_ws"
 printf "  cd %s\n" "$_win_projects"
 printf "  cd %s\n" "$_win_dotfiles"
 printf "  cd %s\n" "$_win_scripts"
 printf "\n\033[36mLabels:\033[0m\n"
 printf "  workstation -> %s\n" "$_win_ws"
 printf "  projects    -> %s\n" "$_win_projects"
 printf "  dotfiles    -> %s\n" "$_win_dotfiles"
 printf "  scripts     -> %s\n" "$_win_scripts"
 printf "\n\033[36mTooling:\033[0m\n"
 if command -v git >/dev/null 2>&1; then printf "  git:     %s\n" "$(git --version | sed 's/git version //')"; else printf "  git:     missing\n"; fi
 if command -v node >/dev/null 2>&1; then printf "  node:    %s\n" "$(node -v)"; else printf "  node:    missing\n"; fi
 if command -v python3 >/dev/null 2>&1; then printf "  python3: %s\n" "$(python3 --version 2>&1 | sed 's/Python //')"; else printf "  python3: missing\n"; fi
 printf "\n\033[36mGitHub CLI:\033[0m\n"
 if command -v wslview >/dev/null 2>&1; then
   printf "  browser bridge: wslview ready\n"
 else
   printf "  browser bridge: install wslu for gh auth login browser flow\n"
 fi
 printf "  login: gh auth login\n"
 printf "  status: gh auth status\n"
 printf "\n"
 exec zsh -il
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

local function wsl_path(path)
  local drive, rest = path:match '^([A-Za-z]):\\(.*)$'

  if drive then
    return '/mnt/' .. drive:lower() .. '/' .. rest:gsub('\\', '/')
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
    args = { git_bash, '--login', '-i', '-c', bash_cmd .. '\nexec bash -il' },
  }
end

local function wsl_spawn(cwd)
  local shell_cmd = ''

  if cwd then
    shell_cmd = 'cd ' .. bash_quote(wsl_path(cwd)) .. ' && '
  end

  return {
    args = { 'wsl.exe', '-d', wsl_distro, 'bash', '-lc', shell_cmd .. 'if command -v zsh >/dev/null 2>&1; then exec zsh -il; else exec bash -il; fi' },
  }
end

local function wsl_command_spawn(cwd, cmd)
  local shell_cmd = ''

  if cwd then
    shell_cmd = 'cd ' .. bash_quote(wsl_path(cwd)) .. ' && '
  end

  return {
    args = { 'wsl.exe', '-d', wsl_distro, 'bash', '-lc', shell_cmd .. cmd },
  }
end

local function wsl_helper_spawn()
  return {
    args = { 'wsl.exe', '-d', wsl_distro, 'bash', '-lc', wsl_helper_cmd },
  }
end

local function ollama_helper_spawn()
  local helper_win = dotfiles .. '\\wezterm\\ollama-helper.sh'
  local fh = io.open(helper_win, 'r')
  if fh then
    fh:close()
    local helper_script = wsl_path(helper_win)
    return {
      args = { 'wsl.exe', '-d', wsl_distro, 'bash', helper_script },
    }
  end
  return {
    args = {
      'wsl.exe',
      '-d',
      wsl_distro,
      'bash',
      '-lc',
      'echo "ollama-helper.sh not in dotfiles/wezterm (optional)."; exec zsh -il',
    },
  }
end

--- If spawn_tab errors (WSL missing, bad distro, etc.), WezTerm aborts gui-startup and only earlier tabs appear.
--- Third return is true when the pwsh fallback tab was used (skip WSL-only splits).
local function spawn_tab_or_fallback(window, spawn_tbl, title, fallback_note)
  local ok, tab, pane = pcall(function()
    return window:spawn_tab(spawn_tbl)
  end)
  if ok and tab then
    tab:set_title(title)
    return tab, pane, false
  end
  wezterm.log_error('WezTerm spawn_tab failed (' .. title .. '): ' .. tostring(tab))
  local ok2, tab2, pane2 = pcall(function()
    return window:spawn_tab(pwsh_spawn(workstation))
  end)
  if ok2 and tab2 then
    tab2:set_title(title .. ' (no WSL)')
    if pane2 and fallback_note then
      pane2:send_text(
        "Write-Host "
          .. "'"
          .. fallback_note
          .. "' -ForegroundColor Yellow; Write-Host 'Install WSL: wsl --install -d Ubuntu-24.04' -ForegroundColor DarkGray\r\n"
      )
    end
    return tab2, pane2, true
  end
  return nil, nil, false
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

  local coding_tab, coding_pane = window:spawn_tab(pwsh_spawn(workstation))
  coding_tab:set_title 'coding'
  coding_pane:split {
    direction = 'Right',
    size = 0.34,
    cwd = workstation,
    args = pwsh_spawn(workstation, coding_helper_cmd).args,
  }

  -- Git tab: left column status (top) + live watch (bottom). Right: workspace clean/dirty + git cheat (pwsh, 10s).
  -- Coding tab right: static CLI reference (no refresh).
  -- Order matters: split Right first, then Bottom on the left pane only.
  local git_tab, git_pane = window:spawn_tab(git_bash_spawn(dotfiles, git_top_helper_cmd))
  git_tab:set_title 'git'
  git_pane:split {
    direction = 'Right',
    size = 0.37,
    cwd = dotfiles,
    args = pwsh_spawn(dotfiles, git_right_panel_cmd).args,
  }
  local git_live_pane = git_pane:split {
    direction = 'Bottom',
    size = 0.35,
    cwd = dotfiles,
    args = git_bash_spawn(dotfiles).args,
  }
  git_live_pane:send_text(git_live_view_cmd .. '\n')

  local wsl_tab, wsl_pane, wsl_fb = spawn_tab_or_fallback(
    window,
    wsl_spawn(workstation),
    'wsl',
    'WSL is not available or the distro failed to start.'
  )
  if wsl_tab and wsl_pane and not wsl_fb then
    wsl_pane:split {
      direction = 'Right',
      size = 0.30,
      args = wsl_helper_spawn().args,
    }
  end

  spawn_tab_or_fallback(
    window,
    wsl_command_spawn(workstation, 'claude'),
    'claude',
    'Install WSL to use Claude CLI in this tab.'
  )

  spawn_tab_or_fallback(
    window,
    wsl_command_spawn(workstation, 'codex'),
    'codex',
    'Install WSL to use Codex CLI in this tab.'
  )

  local ollama_tab, ollama_pane, ollama_fb = spawn_tab_or_fallback(
    window,
    wsl_spawn(workstation),
    'ollama',
    'Install WSL to use Ollama helpers in this tab.'
  )
  if ollama_tab and ollama_pane and not ollama_fb then
    ollama_pane:send_text('qc\n')
    local ok_ollama_split, ollama_helper_pane = pcall(function()
      return ollama_pane:split {
        direction = 'Right',
        size = 0.32,
        args = ollama_helper_spawn().args,
      }
    end)
    if ok_ollama_split and ollama_helper_pane then
      pcall(function()
        ollama_helper_pane:split {
          direction = 'Bottom',
          size = 0.33,
          args = wsl_spawn(workstation).args,
        }
      end)
    end
  end

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
config.window_close_confirmation = 'NeverPrompt'

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
    cwd = dotfiles .. '\\scripts',
  },
  {
    label = 'wsl — ubuntu zsh',
    args = { 'wsl.exe', '-d', wsl_distro, 'bash', '-lc', 'exec zsh -il' },
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
  { key = '6', mods = 'ALT', action = act.ActivateTab(5) },
  { key = '7', mods = 'ALT', action = act.ActivateTab(6) },
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
  { key = 'q', mods = 'CTRL|SHIFT', action = act.QuitApplication },
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
