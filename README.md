# dotfiles

> Personal Windows dotfiles — configs, tools, and a one-command machine bootstrap.

---

## ⚡ Fresh Machine Setup

Use this on a **brand-new Windows PC** before you do anything else. Order matters: Git must exist so the bootstrap can clone repos; `winget` must work so apps can install.

**Username:** Nothing here is tied to the name `rjh`. The installer and profile use **`$HOME\workstation\...`** (same as **`%USERPROFILE%\workstation\...`** on disk). If your account is `alex`, you get `C:\Users\alex\workstation\...`. Forks and docs that still show `C:\Users\rjh\...` are just the author’s machine—substitute your profile path or use `$HOME` in PowerShell.

### 1. Open PowerShell

Use **Windows PowerShell** or **PowerShell 7** (either is fine for the steps below). You do not need admin for Git or the remote install line; you will need admin later if you want Windows tweaks applied automatically (the installer will tell you).

### 2. Confirm `winget` (Windows Package Manager)

The installer uses `winget` to import your app list. On Windows 11 it is usually already available.

```powershell
winget --version
```

If that fails:

- **Windows 11:** Install pending updates, or install [App Installer](https://apps.microsoft.com/detail/9nblggh4nns1) from the Microsoft Store.
- **Windows 10:** Install **App Installer** from the Store (same link), or see [Microsoft’s winget install docs](https://learn.microsoft.com/windows/package-manager/winget/).

### 3. Install Git (required before the one-liner)

The remote bootstrap runs `git clone`. Install Git first, then **open a new terminal** so `git` is on your `PATH`.

**Recommended (matches the rest of your stack):**

```powershell
winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
```

**Alternative:** Download and run the installer from [git-scm.com/download/win](https://git-scm.com/download/win). Use the default options unless you know you want something different; ensure **“Git from the command line and also from 3rd-party software”** (or equivalent) is selected so PowerShell can find `git`.

**Verify:**

```powershell
git --version
```

You should see something like `git version 2.x.x`.

### 4. Run the bootstrap (one command)

```powershell
irm https://raw.githubusercontent.com/hedglen/dotfiles/master/install.ps1 | iex
```

This will:

1. Clone this repo to `$HOME\workstation\dotfiles` (i.e. `%USERPROFILE%\workstation\dotfiles`)
2. Clone remaining workspace repo (`hedglen-profile`) and create `projects/` directory. Utility scripts live under `scripts/` in this repo. Personal notes live in this repo under `notes/`.
3. Install apps: `winget import` from **`apps/winget-packages.json`**; then install **Scoop** via **get.scoop.sh** if needed and **`scoop install`** every name in **`apps/scoop-packages.json`** (see **`apps/winget-packages.md`** / **`apps/scoop-packages.md`**)
4. Apply Windows tweaks (requires admin)
5. Symlink all configs to their correct locations
6. Install all VS Code extensions
7. Install CaskaydiaCove Nerd Font
8. Clone the mpv config
9. Register AutoHotkey on startup

---

## 🗂️ What's In Here

```text
dotfiles/
├── install.ps1                    ← bootstrap script
├── autohotkey/
│   └── main.ahk                   ← hotkeys, app launchers, text expanders
├── powershell/
│   └── profile.ps1                ← prompt, aliases, helper functions
├── shell/
│   └── git-aware-ll.bash          ← optional Git Bash `ll`: colors git subdirs green (clean) / yellow (dirty); source from `~/.bashrc`
├── oh-my-posh/
│   └── hedglab.omp.json           ← custom OMP theme (Neon Dark–style segments)
├── wezterm/
│   ├── wezterm.lua                ← gui-startup tabs: system (dashboard + helper names), coding (CLI cheat sheet in right split), git (workspace status + commit steps), wsl, ollama
│   └── ollama-helper.sh           ← live Ollama status pane used by the WezTerm ollama tab
├── wsl/
│   ├── .zshrc                     ← WSL shell aliases, workstation helpers, ollama shortcuts
│   ├── .p10k.zsh                  ← WSL Powerlevel10k prompt
│   └── README.md                  ← sync instructions for the tracked WSL shell files
├── vscode/
│   ├── settings.json              ← editor settings, font, theme
│   └── extensions.txt             ← extension list for auto-install
├── windows-terminal/
│   └── settings.json              ← Neon Dark terminal scheme, Nerd Font, keybindings
├── windows/
│   └── tweaks.ps1                 ← privacy, power, explorer tweaks
├── scripts/
│   ├── workstation-health.ps1      ← quick layout + tooling check
│   ├── transcribe.py / .ps1       ← media helpers (see scripts/README.md)
│   ├── python/                     ← cross-platform CLI helpers
│   └── README.md
├── notes/
│   ├── README.md                  ← README + personal/tech/work folders
│   ├── personal/
│   ├── tech/
│   └── work/
├── git/
│   └── .gitconfig                 ← aliases, colors, sensible defaults
└── apps/
    ├── winget-packages.json       ← full app list for winget import
    ├── winget-packages.md         ← what each winget package is for
    ├── scoop-packages.json        ← CLI apps installed via Scoop (manual after Scoop setup)
    └── scoop-packages.md          ← what each Scoop package is for
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
| --- | --- |
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

- A multi-color neon cheat sheet lists helper commands (cyan, magenta, **bold red** `ytdl`, sky blue, orange, mint); random quotes use **gold** (`#FFD447`)
- A random quote prints in dim grey underneath

### PSReadLine

- Inline suggestions sourced from command history (shown in blue as you type)
- Press `→` to accept a suggestion

### Prompt

Format: `[USER/ADMIN] HH:MM PS path>`

| Element | Color |
| --- | --- |
| `[USER]` / `[ADMIN]` tag | Neon green |
| Time | Bright green |
| `PS` label | Magenta |
| Current path | Yellow/orange |

### Navigation

| Command | Description |
| --- | --- |
| `c` | `cd C:\` |
| `d` | `cd D:\` |
| `home` | `cd ~` |
| `dots` | `cd $HOME\workstation\dotfiles` |
| `tools` | `cd $HOME\workstation\tools` |
| `psh` | `cd $HOME\workstation\tools\powershell` |

### System Helpers

| Command | Description |
| --- | --- |
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
| --- | --- |
| `ll` / `la` | `Get-ChildItem` |
| `open` | `Invoke-Item` |
| `startup-list` | `Get-StartupList` |
| `startup-find` | `Search-Startup` |
| `tasks-user` | `Get-UserTasks` |
| `uptime` | `Get-Uptime` |

### Directory Colors

| Type | Color |
| --- | --- |
| Directories | Soft cyan |
| Executables | Warm yellow |

---

## ⌨️ AutoHotkey

Script: `autohotkey/main.ahk` — loads on startup via registry Run key.

### App Launchers (Win + Key)

| Hotkey | Action |
| --- | --- |
| `Win+T` | Windows Terminal (PowerShell) — suppressed when mpv is focused |
| `Win+E` | Directory Opus → File Pilot → Explorer (first found) |
| `Win+B` | Brave if installed, else **Chrome** (matches `winget-packages.json` default) |
| `Win+N` | **Firefox** (winget) |
| `Win+O` | Obsidian |
| `Win+C` | VS Code (`code`) |

### Window Management

| Hotkey | Action |
| --- | --- |
| `Win+Alt+Left` | Move window to left monitor |
| `Win+Alt+Right` | Move window to right monitor |
| `Win+Alt+F` | Toggle true fullscreen (borderless, any window) |

### Clipboard

| Hotkey | Action |
| --- | --- |
| `Ctrl+Shift+V` | Paste as plain text (strips formatting) |

### Text Expanders

| Trigger | Expands To |
| --- | --- |
| `@@` | `hedglen@pm.me` |
| `/shrug` | `¯\_(ツ)_/¯` |
| `/check` | `✓` |
| `/arr` | `→` |
| `/date` | Today's date (`YYYY-MM-DD`) |

---

## 🖥️ Windows Terminal

### Keyboard Bindings

| Hotkey | Action |
| --- | --- |
| `Ctrl+T` | New tab |
| `Ctrl+W` | Close tab |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Alt+Shift+D` | Duplicate pane (auto-split) |
| `Alt+Shift+Right` | Split pane right |
| `Alt+Shift+Down` | Split pane down |

### Profiles

| Profile | Status |
| --- | --- |
| PowerShell 7 (pwsh) | Default |
| Windows PowerShell | Available |
| Command Prompt | Hidden |
| Azure Cloud Shell | Hidden |

### Cursor

| Setting | Value |
| --- | --- |
| Shape | Bar (vertical “I”) |
| Blink | On (`cursorBlinking`: `blink` in `windows-terminal/settings.json`; `terminal.integrated.cursorBlinking` in VS Code) |

### Color Schemes

**Neon Dark** (active) — aligned with Sudhan’s [Neon Dark Theme](https://marketplace.visualstudio.com/items?itemName=Sudhan.neondark-theme): near-black base, light text, magenta/cyan/gold accents (see `settings.json` schemes).

| Element | Color |
| --- | --- |
| Background | `#0E0E0E` |
| Foreground | `#E4E4E4` |
| Magenta (keywords) | `#E954FF` / bright `#F4A4FF` |
| Cyan (types) | `#00E8FF` / bright `#66F9FF` |
| Blue (sky) | `#64B5FF` / bright `#A8D4FF` |
| Yellow (strings) | `#FFD447` / bright `#FFE566` |
| Red/pink | `#FF6B8A` |
| Teal/green | `#00E8B5` |
| Cursor | `#FF66EE` |
| Selection | `#3D2560` |

**Neon Blaze** — legacy neon green/purple palette (still in `settings.json` if you switch profile scheme).

**Catppuccin Mocha** — soft pastel dark theme (available, not active)

---

## 🧩 VS Code

### Key Settings

| Setting | Value |
| --- | --- |
| Theme | Neon Dark ([Sudhan.neondark-theme](https://marketplace.visualstudio.com/items?itemName=Sudhan.neondark-theme)) |
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
| Terminal cursor | Line + blink (`terminal.integrated.cursorStyle` / `cursorBlinking`) |

**Cursor:** the same `vscode/settings.json` is symlinked to `%APPDATA%\Cursor\User\settings.json` by `install.ps1` / `update.ps1`, so integrated-terminal options (font, Neon Dark colors, **blinking bar cursor**) apply in Cursor—not only in VS Code.

### Extensions

| Category | Extension |
| --- | --- |
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
| --- | --- |
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
| --- | --- | --- |
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

## 📦 Apps (winget + Scoop)

**Winget** and **Scoop** lists both live under **`apps/`** and are the only source of truth. **`install.ps1`** runs `winget import` on `winget-packages.json`, then installs **Scoop** from **get.scoop.sh** if it is missing, then **`scoop install`** for every name in `scoop-packages.json`. Use **`-NoScoop`** to skip Scoop entirely while still running winget. **`maintenance/update.ps1`** upgrades winget IDs from the JSON and runs **`scoop update *`**. Notes: **`apps/winget-packages.md`**, **`apps/scoop-packages.md`**.

For **how to use** installed apps and profile helpers (not just the install list), see the companion doc **`docs/guides/workstation-tools.md`** in your [docs](https://github.com/hedglen/docs) clone (`%USERPROFILE%\workstation\docs\guides\workstation-tools.md` on disk).

| Category | Apps (from `apps/winget-packages.json`) |
| --- | --- |
| **Dev / runtimes** | Git, VS Code, **Notepad++**, Windsurf, Cursor, Claude (desktop), Ollama, PowerShell 7, Python Launcher, AutoHotkey, Node.js LTS, Deno, JetBrainsMono Nerd Font; .NET Desktop + .NET runtimes, VC++ redists, VCLibs, App Installer, UI XAML, Windows App Runtime; **WSL** + **Ubuntu 24.04** |
| **CLI (Scoop)** | Full list in `apps/scoop-packages.json` — see **`apps/scoop-packages.md`** |
| **Terminal / shell** | Windows Terminal, WezTerm, Oh My Posh (winget) |
| **Browsers** | Chrome, Firefox, Vivaldi |
| **Media** | PotPlayer, mpv (shinchiro build), ShareX, Bandicut, yt-dlp + FFmpeg, XnViewMP, HandBrake, OBS Studio, MediaInfo, ImageGlass, ScreenToGif, SumatraPDF |
| **File management** | Everything, Directory Opus, NanaZip, Bulk Rename Utility, WizTree |
| **Productivity** | Obsidian, LibreOffice, Calibre, Thorium, Zoom, LocalSend, EarTrumpet, ModernCSV, DupeGuru, Tesseract OCR, Qobuz, **foobar2000**, PawnIO |
| **Creative** | Adobe Creative Cloud |
| **Privacy / chat** | Proton VPN, Drive, Pass, Authenticator; Signal; **Discord** |
| **Cloud / downloads** | Google Drive, pCloud Drive; Internet Download Manager, JDownloader |
| **System / hardware** | HWiNFO, CrystalDiskInfo, MSI Afterburner, FanControl, AOMEI Partition Assistant, Sysinternals, UniGetUI, Corsair iCUE 5, Logitech G HUB |
| **Desktop shell** | StartAllBack, PowerToys, TranslucentTB |
| **Games** | Steam, Paradox launcher |

### Scoop (CLI packages)

**`install.ps1`** installs [Scoop](https://github.com/ScoopInstaller/Install) from **get.scoop.sh** when needed, then `scoop install` for every entry in `apps/scoop-packages.json`. To install or refresh manually:

```powershell
Set-Location "$HOME\workstation\dotfiles\apps"
$pkgs = (Get-Content .\scoop-packages.json -Raw | ConvertFrom-Json).packages
scoop install @pkgs
```

`zoxide` is the usual **z**-style directory jumper (`z`, `zi` after you hook it in your shell). Per-tool notes: **`apps/scoop-packages.md`**.

Many GUI apps and heavy runtimes stay on **winget** (see `apps/winget-packages.json`). Add `scoop bucket add extras` if you later install Scoop-only GUI apps.

#### GitHub CLI (`gh`)

The `gh` binary is **not** logged into GitHub until you authenticate.

1. Open PowerShell (or any terminal where `gh` is on your `PATH`).
2. Run:

```powershell
gh auth login
```

3. Follow the prompts: choose **GitHub.com**, preferred protocol (**HTTPS** or **SSH**), and sign in via **browser** or paste a **personal access token**.

After that, `gh repo clone`, `gh pr create`, and other `gh` commands use your account. This is separate from `git`’s own credential helper unless you deliberately use the same method (for example, HTTPS with the same stored token).

##### WSL Note

If you run `gh auth login` inside WSL, install `wslu` first so browser login opens correctly in Windows:

```bash
sudo apt update
sudo apt install -y wslu
gh auth login
```

Recommended WSL answers:

- account: `GitHub.com`
- protocol: `HTTPS`
- authenticate Git with GitHub credentials: `Yes`
- auth method: `Login with a web browser`

If the browser handoff still misbehaves, open [github.com/login/device](https://github.com/login/device) in Windows and enter the one-time code shown by `gh`.

---

## 🔧 Manual Installs

These apps are **not** listed in `apps/winget-packages.json` and must be installed manually. (**JDownloader** is available via winget as `AppWork.JDownloader` in this repo; use a manual install only if you prefer the website build or a portable layout.)

### 🟢 Macrium Reflect Home

- **Download:** [macrium.com/reflectfree](https://www.macrium.com/reflectfree)
- **Install:** Run installer, select "Home" edition (free)
- **Note:** Re-register email after install to unlock scheduling

### 🟠 Battle.net

- **Download:** [battle.net installer](https://us.battle.net/download/getBnetInstaller)
- **Install:** Run Battle.net installer, log in with Blizzard account
- **Account:** stored in Bitwarden

---

## 🔑 Licenses & Accounts

> ⚠️ **Keys are NOT stored here.** This is a public repo.
> All license keys and passwords are stored in **Proton Pass** under `Software Licenses`.

| App | Type | Where |
| --- | --- | --- |
| StartAllBack | Paid license | Proton Pass → Software Licenses |
| Internet Download Manager | Paid license | Proton Pass → Software Licenses |
| Adobe Creative Cloud | Subscription | Proton Pass → Adobe |
| Corsair iCUE | Free (account optional) | [hedglen@pm.me](mailto:hedglen@pm.me) |
| Proton (VPN/Drive/Pass/Auth) | Subscription | master password — memorize it |
| JDownloader 2 | Free (account optional) | Proton Pass → JDownloader |
| Battle.net / Blizzard | Account | Proton Pass → Blizzard |
| Steam | Account | Proton Pass → Steam |

---

## 🎨 Oh My Posh Theme

Theme: `oh-my-posh/hedglab.omp.json` — diamond **shell** chip, powerline **path** / **git** / **timing** / **exit**, plus a right-aligned **clock**.

| Segment | Colors | Shows |
| --- | --- | --- |
| Shell | Diamond, BG `#E954FF`, text `#0E0E0E` | Nerd icon + shell name (`pwsh`, …) |
| Path | BG `#1B2B38`, text `#66F9FF` | Full path, `/` separators (avoids Powerline PUA glitches in some terminals) |
| Git | BG `#FFD447`, text `#0E0E0E` | Branch (powerline branch icon), status, stash |
| Exec time | BG `#00E8B5`, text `#0E0E0E` | How long the last command took |
| Exit code | Diamond, BG `#FF6B8A`, text `#FFFFFF` | Success or failure of last command |
| Time | Plain, `#64B5FF` | Current time (`HH:mm:ss`), clock icon |

To activate it, add this to your profile (Oh My Posh is already installed via winget):

```powershell
oh-my-posh init pwsh --config "$HOME\workstation\dotfiles\oh-my-posh\hedglab.omp.json" | Invoke-Expression
```

---

## 🎨 Terminal Theme — Neon Dark

CaskaydiaCove Nerd Font is installed automatically by `install.ps1` (step 7). No manual download needed.

The **Neon Dark** scheme (matched to Sudhan’s VS Code [Neon Dark Theme](https://marketplace.visualstudio.com/items?itemName=Sudhan.neondark-theme)) is defined in `windows-terminal/settings.json` and mirrored in `vscode/settings.json` (`terminal.integrated.*` + `workbench.colorCustomizations`) so Windows Terminal and the VS Code integrated terminal stay consistent. **Neon Blaze** remains in `settings.json` if you want the old green-accent look.

---

## 🖥️ Related

- **[Workstation tools guide](https://github.com/hedglen/docs/blob/main/guides/workstation-tools.md)** — practical map of winget/Scoop apps, PowerShell helpers (`ytdl`, `orgmed`, `trans`, …), and links to upstream docs
- **`apps/winget-packages.md`** / **`apps/scoop-packages.md`** — short description + example use for each package ID / Scoop name
- **[mpv-config](https://github.com/hedglen/mpv-config)** — full mpv media player setup with HDR auto-switching, FSRCNNX/Anime4K shaders, ultrawide optimization, Corsair Scimitar button mapping, chapter editor, clip export, GIF creation, favorites, audio normalize, and more
