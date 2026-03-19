# dotfiles

> Personal Windows dotfiles — configs, tools, and a one-command machine bootstrap.

---

## ⚡ Fresh Machine Setup

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/hedglen/dotfiles/master/install.ps1 | iex
```

**Requires:** [Git](https://git-scm.com) installed first.

This will:
1. Clone this repo to `~/dotfiles`
2. Install all apps via winget
3. Apply Windows tweaks (requires admin)
4. Symlink all configs to their correct locations
5. Install all VS Code extensions
6. Install CaskaydiaCove Nerd Font
7. Clone the mpv config
8. Register AutoHotkey on startup

---

## 🗂️ What's In Here

```
dotfiles/
├── install.ps1                    ← bootstrap script
├── autohotkey/
│   └── main.ahk                   ← hotkeys, app launchers, text expanders
├── powershell/
│   └── profile.ps1                ← prompt, aliases, helper functions
├── oh-my-posh/
│   └── hedglab.omp.json           ← custom OMP theme (purple/pink/cyan)
├── vscode/
│   ├── settings.json              ← editor settings, font, theme
│   └── extensions.txt             ← extension list for auto-install
├── windows-terminal/
│   └── settings.json              ← Neon Blaze theme, Nerd Font, keybindings
├── windows/
│   └── tweaks.ps1                 ← privacy, power, explorer tweaks
├── git/
│   └── .gitconfig                 ← aliases, colors, sensible defaults
└── apps/
    └── winget-packages.json       ← full app list for winget import
```

---

## 🔧 Install Options

```powershell
# Full install (default)
.\install.ps1

# Only install apps, skip config linking
.\install.ps1 -AppsOnly

# Only link configs, skip app install
.\install.ps1 -ConfigsOnly

# Skip app installation
.\install.ps1 -NoApps

# Preview what would happen without doing anything
.\install.ps1 -DryRun
```

---

## 🔄 Keeping Up to Date

After initial setup, two commands handle ongoing maintenance:

| Command | What it does |
|---------|-------------|
| `save-dots` | Commit & push your local changes to GitHub |
| `sync-dots` | Pull latest from GitHub, relink any new configs, install new extensions/fonts |

For a full system update (apps + dotfiles):

```powershell
.\maintenance\update.ps1
```

Options:

```powershell
.\maintenance\update.ps1 -SkipApps   # pull + relink only, no winget upgrade
.\maintenance\update.ps1 -SkipDots   # winget upgrade only, skip git pull
.\maintenance\update.ps1 -DryRun     # preview without making changes
```

---

## 💻 PowerShell Profile

### Startup Banner

On every new terminal:
- A neon purple cheat sheet lists all available commands
- A random quote prints in dim grey underneath

### PSReadLine

- Inline suggestions sourced from command history (shown in blue as you type)
- Press `→` to accept a suggestion

### Prompt

Format: `[USER/ADMIN] HH:MM PS path>`

| Element | Color |
|---------|-------|
| `[USER]` / `[ADMIN]` tag | Neon green |
| Time | Bright green |
| `PS` label | Magenta |
| Current path | Yellow/orange |

### Navigation

| Command | Description |
|---------|-------------|
| `c` | `cd C:\` |
| `d` | `cd D:\` |
| `home` | `cd ~` |
| `dots` | `cd ~/dotfiles` |
| `tools` | `cd C:\Tools` |
| `psh` | `cd C:\Tools\PowerShell` |

### System Helpers

| Command | Description |
|---------|-------------|
| `drives` | All volumes with size and free space |
| `uptime` | Time since last boot (`Xd Xh Xm`) |
| `sysinfo` | OS, uptime, RAM, CPU, user, hostname |
| `users` | Local user accounts |
| `admins` | Local admin group members |
| `startup-list` | All startup entries (registry + startup folder) |
| `startup-find 'pattern'` | Search startup entries by name or path |
| `tasks-user` | Non-Microsoft scheduled tasks |
| `pkillf name` | Force-kill all processes matching name |
| `which name` | Find where a command lives |
| `touch path` | Create an empty file |
| `grep pattern` | Pipeline-friendly `Select-String` wrapper |
| `reload` | Re-source the profile in the current session |
| `save-dots [message]` | Commit & push all dotfile changes to GitHub |

### Aliases

| Alias | Resolves To |
|-------|-------------|
| `ll` / `la` | `Get-ChildItem` |
| `open` | `Invoke-Item` |
| `startup-list` | `Get-StartupList` |
| `startup-find` | `Search-Startup` |
| `tasks-user` | `Get-UserTasks` |
| `uptime` | `Get-Uptime` |

### Directory Colors

| Type | Color |
|------|-------|
| Directories | Soft cyan |
| Executables | Warm yellow |

---

## ⌨️ AutoHotkey

Script: `autohotkey/main.ahk` — loads on startup via registry Run key.

### App Launchers (Win + Key)

| Hotkey | Action |
|--------|--------|
| `Win+T` | Windows Terminal (PowerShell) — suppressed when mpv is focused |
| `Win+E` | File Pilot (file manager) |
| `Win+B` | Brave Browser |
| `Win+N` | Notion |
| `Win+O` | Obsidian |
| `Win+C` | VS Code (dotfiles workspace) |

### Window Management

| Hotkey | Action |
|--------|--------|
| `Win+Alt+Left` | Move window to left monitor |
| `Win+Alt+Right` | Move window to right monitor |
| `Win+Alt+F` | Toggle true fullscreen (borderless, any window) |

### Clipboard

| Hotkey | Action |
|--------|--------|
| `Ctrl+Shift+V` | Paste as plain text (strips formatting) |

### Text Expanders

| Trigger | Expands To |
|---------|-----------|
| `@@` | `hedglen@pm.me` |
| `/shrug` | `¯\_(ツ)_/¯` |
| `/check` | `✓` |
| `/arr` | `→` |
| `/date` | Today's date (`YYYY-MM-DD`) |

---

## 🖥️ Windows Terminal

### Keyboard Bindings

| Hotkey | Action |
|--------|--------|
| `Ctrl+T` | New tab |
| `Ctrl+W` | Close tab |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Alt+Shift+D` | Duplicate pane (auto-split) |
| `Alt+Shift+Right` | Split pane right |
| `Alt+Shift+Down` | Split pane down |

### Profiles

| Profile | Status |
|---------|--------|
| PowerShell 7 (pwsh) | Default |
| Windows PowerShell | Available |
| Command Prompt | Hidden |
| Azure Cloud Shell | Hidden |

### Color Schemes

**Neon Blaze** (active) — neon green on near-black

| Element | Color |
|---------|-------|
| Background | `#0A0A0F` |
| Foreground | `#39FF14` (neon green) |
| Blue / Bright Blue | `#BF00FF` / `#D966FF` (purple) |
| Red | `#FF2D55` |
| Cyan | `#00FFCC` |
| Yellow | `#FF6000` |
| Cursor | `#FF6000` |
| Selection | `#3D0066` |

**Catppuccin Mocha** — soft pastel dark theme (available, not active)

---

## 🧩 VS Code

### Key Settings

| Setting | Value |
|---------|-------|
| Theme | One Dark Pro |
| Icons | Material Icon Theme |
| Font | Cascadia Code / Fira Code / Consolas |
| Font size | 14 |
| Ligatures | Enabled |
| Tab size | 4 spaces |
| Format on save | Enabled |
| Auto save | On focus change |
| Minimap | Disabled |
| Sticky scroll | Enabled |
| Ruler | 100 chars |
| Terminal font | CaskaydiaCove Nerd Font |
| Terminal font size | 13 |
| Terminal default | PowerShell |

### Extensions

| Category | Extension |
|----------|-----------|
| AI | Claude Code, GitHub Copilot, Copilot Chat |
| Git | GitLens |
| PowerShell | ms-vscode.powershell |
| Python | ms-python.python (Pylance) |
| Lua | sumneko.lua |
| AutoHotkey | thqby.vscode-autohotkey2-lsp |
| Data/Config | redhat.vscode-yaml, rainbow-csv |
| Formatting | Prettier |
| QoL | Error Lens, Material Icons, Better Comments, Path Intellisense |
| Remote | Remote SSH, Remote Explorer |

---

## 🔀 Git

Config: `git/.gitconfig` — symlinked to `~/.gitconfig` on install.

### Shortcuts (aliases)

Instead of typing full git commands, these short versions work:

| Type this | Instead of |
|-----------|-----------|
| `git st` | `git status` |
| `git co` | `git checkout` |
| `git br` | `git branch` |
| `git cp` | `git cherry-pick` |
| `git rb` | `git rebase` |
| `git lg` | `git log --oneline --graph --decorate --all` (pretty branch tree) |
| `git ll` | last 20 commits, one line each |
| `git last` | last commit with which files changed |
| `git undo` | undo last commit but keep the changes |
| `git unstage file` | remove a file from staging area |
| `git discard file` | throw away changes to a file |
| `git changed` | list files changed in the last commit |
| `git branches` | list all branches (local + remote) |
| `git stashes` | list all stashes |

### Sensible Defaults

| Setting | Value | What it means |
|---------|-------|---------------|
| `defaultBranch` | `main` | New repos start on `main` not `master` |
| `autocrlf` | `input` | Don't mangle line endings on Windows |
| `editor` | `code --wait` | VS Code opens for commit messages |
| `pull.rebase` | `false` | `git pull` merges, doesn't rebase |
| `push.autoSetupRemote` | `true` | First push sets upstream automatically |
| `fetch.prune` | `true` | Auto-delete stale remote branches |
| `diff.colorMoved` | `zebra` | Moved code shows differently in diffs |
| `merge.conflictStyle` | `diff3` | Merge conflicts show the original too |

---

## 🔒 Windows Tweaks

Script: `windows/tweaks.ps1` — run during install (admin required).

**Power:**
- High Performance power plan
- Fast startup disabled
- Sleep on AC disabled
- Hard disk sleep disabled

**Privacy:**
- Telemetry set to 0, DiagTrack & dmwappushservice disabled
- Advertising ID, tailored experiences, activity history disabled
- Location services disabled
- Camera/mic/location denied by default for Store apps

**Xbox / Game Bar:**
- Game DVR, Game Bar, background recording disabled
- Xbox services disabled

**Explorer:**
- File extensions visible
- Hidden files visible
- Opens to This PC (not Quick Access)
- Recent/frequent items in Quick Access disabled

**Start / Search / Taskbar:**
- Bing search in Start disabled
- Cortana disabled
- News & Interests widget disabled
- Suggested/promoted apps disabled

---

## 📦 Apps (via winget)

Key apps tracked in `apps/winget-packages.json` (~60 packages total):

| Category | Apps |
|----------|------|
| **Dev** | Git, VS Code, PowerShell 7, Python Launcher, AutoHotkey |
| **Terminal** | Windows Terminal, Oh My Posh |
| **Browsers** | Brave, Floorp, Chrome |
| **Media** | VLC, MPC-BE, PotPlayer, ShareX, Bandicut, yt-dlp, XnViewMP |
| **File Management** | File Pilot, Everything, TeraCopy, NanaZip, 7-Zip, Bulk Rename, TreeSize, Ditto |
| **Productivity** | Notion, Obsidian, LibreOffice, Flow Launcher, Zoom, LocalSend, EarTrumpet |
| **Creative** | Adobe Creative Cloud, Adobe Acrobat Reader |
| **Privacy** | Proton VPN, Proton Drive, Proton Pass, Proton Authenticator, Bitwarden, Signal |
| **Cloud** | Google Drive, pCloud Drive |
| **System** | MSI Afterburner, HWiNFO, CrystalDiskInfo, FanControl, AOMEI Partition Assistant |
| **Entertainment** | Steam, Kodi, Jellyfin Server |
| **Package Mgmt** | UniGetUI |
| **Other** | StartAllBack, Internet Download Manager, Corsair iCUE 5 |

### CLI Tools (winget)

These are the everyday CLI search/navigation tools:

```powershell
winget install -e --id BurntSushi.ripgrep.MSVC
winget install -e --id junegunn.fzf
winget install -e --id sharkdp.fd
winget install -e --id sharkdp.bat
```

---

## 🔧 Manual Installs

These apps are **not available in winget** and must be installed manually.

### 🔵 JDownloader 2
- **Download:** https://jdownloader.org/download/index
- **Install:** Run installer, sign into My JDownloader account
- **Account:** hedglen@pm.me

### 🟢 Macrium Reflect Home
- **Download:** https://www.macrium.com/reflectfree
- **Install:** Run installer, select "Home" edition (free)
- **Note:** Re-register email after install to unlock scheduling

### 🟠 Battle.net
- **Download:** https://us.battle.net/download/getBnetInstaller
- **Install:** Run Battle.net installer, log in with Blizzard account
- **Account:** stored in Bitwarden

---

## 🔑 Licenses & Accounts

> ⚠️ **Keys are NOT stored here.** This is a public repo.
> All license keys and passwords are stored in **Proton Pass** under `Software Licenses`.

| App | Type | Where |
|-----|------|-------|
| StartAllBack | Paid license | Proton Pass → Software Licenses |
| Internet Download Manager | Paid license | Proton Pass → Software Licenses |
| Adobe Creative Cloud | Subscription | Proton Pass → Adobe |
| Corsair iCUE | Free (account optional) | hedglen@pm.me |
| Proton (VPN/Drive/Pass/Auth) | Subscription | master password — memorize it |
| JDownloader 2 | Free (account optional) | Proton Pass → JDownloader |
| Battle.net / Blizzard | Account | Proton Pass → Blizzard |
| Steam | Account | Proton Pass → Steam |

---

## 🎨 Oh My Posh Theme

Theme: `oh-my-posh/hedglab.omp.json` — a custom powerline prompt with four segments:

| Segment | Background | Shows |
|---------|-----------|-------|
| Path | Purple `#6a0dad` | Full folder path |
| Git | Deep pink `#ff1493` | Branch, status, stash count |
| Exec time | Cyan `#00ffcc` | How long the last command took |
| Exit code | Red `#ff5555` | Success or failure of last command |

To activate it, add this to your profile (Oh My Posh is already installed via winget):

```powershell
oh-my-posh init pwsh --config "$HOME\dotfiles\oh-my-posh\hedglab.omp.json" | Invoke-Expression
```

---

## 🎨 Terminal Theme — Neon Blaze

CaskaydiaCove Nerd Font is installed automatically by `install.ps1` (step 6). No manual download needed.

The **Neon Blaze** color scheme is defined in both `windows-terminal/settings.json` and `vscode/settings.json` so the terminal looks identical everywhere.

---

## 🖥️ Related

- **[mpv-config](https://github.com/hedglen/mpv-config)** — full mpv media player setup with HDR auto-switching, FSRCNNX/Anime4K shaders, ultrawide optimization, Corsair Scimitar button mapping, chapter editor, clip export, GIF creation, favorites, audio normalize, and more
