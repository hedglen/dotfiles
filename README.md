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
2. Clone remaining workspace repos (`scripts`, `docs`, `hedglen-profile`) and create `projects/` directory
3. Install all apps via winget
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
├── oh-my-posh/
│   └── hedglab.omp.json           ← custom OMP theme (Neon Dark–style segments)
├── vscode/
│   ├── settings.json              ← editor settings, font, theme
│   └── extensions.txt             ← extension list for auto-install
├── windows-terminal/
│   └── settings.json              ← Neon Dark terminal scheme, Nerd Font, keybindings
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

- A multi-color neon cheat sheet lists helper commands (cyan, magenta, gold, sky blue, orange, mint)
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
| `Win+E` | File Pilot (file manager) |
| `Win+B` | Brave Browser |
| `Win+N` | Notion |
| `Win+O` | Obsidian |
| `Win+C` | VS Code (dotfiles workspace) |

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

## 📦 Apps (via winget)

Key apps tracked in `apps/winget-packages.json` (see the file for the full list):

| Category | Apps |
| --- | --- |
| **Dev** | Git, VS Code, PowerShell 7, Python Launcher, AutoHotkey, ripgrep, fzf, fd, bat, GitHub CLI, zoxide |
| **Terminal** | Windows Terminal, Oh My Posh |
| **Browsers** | Brave, Floorp, Chrome |
| **Media** | MPC-BE, PotPlayer, ShareX, Bandicut, yt-dlp, XnViewMP |
| **File Management** | File Pilot, Everything, TeraCopy, NanaZip, 7-Zip, Bulk Rename, TreeSize, Ditto |
| **Productivity** | Notion, Obsidian, LibreOffice, Calibre, Thorium Reader, Flow Launcher, Zoom, LocalSend, EarTrumpet |
| **Creative** | Adobe Creative Cloud, Adobe Acrobat Reader |
| **Privacy** | Proton VPN, Proton Drive, Proton Pass, Proton Authenticator, Bitwarden, Signal |
| **Cloud** | Google Drive, pCloud Drive |
| **System** | MSI Afterburner, HWiNFO, CrystalDiskInfo, FanControl, AOMEI Partition Assistant |
| **Entertainment** | Steam |
| **Package Mgmt** | UniGetUI |
| **Other** | StartAllBack, Internet Download Manager, Corsair iCUE 5, Logitech G HUB |

### CLI Tools (winget)

These are installed automatically with `install.ps1` / `winget import` (listed in `apps/winget-packages.json`). To add or refresh one package by hand:

```powershell
winget install -e --id BurntSushi.ripgrep.MSVC
winget install -e --id junegunn.fzf
winget install -e --id sharkdp.fd
winget install -e --id sharkdp.bat
winget install -e --id GitHub.cli
winget install -e --id ajeetdsouza.zoxide
```

`zoxide` is the usual **z**-style directory jumper (`z`, `zi` after you hook it in your shell).

#### GitHub CLI (`gh`)

Winget only installs the `gh` program. It is **not** logged into GitHub until you authenticate.

1. Open PowerShell (or any terminal where `gh` is on your `PATH`).
2. Run:

```powershell
gh auth login
```

3. Follow the prompts: choose **GitHub.com**, preferred protocol (**HTTPS** or **SSH**), and sign in via **browser** or paste a **personal access token**.

After that, `gh repo clone`, `gh pr create`, and other `gh` commands use your account. This is separate from `git`’s own credential helper unless you deliberately use the same method (for example, HTTPS with the same stored token).

---

## 🔧 Manual Installs

These apps are **not available in winget** and must be installed manually.

### 🔵 JDownloader 2

- **Download:** [jdownloader.org/download/index](https://jdownloader.org/download/index)
- **Install:** Run installer, sign into My JDownloader account
- **Account:** [hedglen@pm.me](mailto:hedglen@pm.me)

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
| Path | BG `#1B2B38`, text `#66F9FF` | Full path, folder icon, `\ue0b1` separators |
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

- **[mpv-config](https://github.com/hedglen/mpv-config)** — full mpv media player setup with HDR auto-switching, FSRCNNX/Anime4K shaders, ultrawide optimization, Corsair Scimitar button mapping, chapter editor, clip export, GIF creation, favorites, audio normalize, and more
