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
3. Install Oh My Posh
4. Symlink all configs to their correct locations
5. Install all VS Code extensions
6. Clone the mpv config

---

## 🗂️ What's In Here

```
dotfiles/
├── install.ps1                    ← bootstrap script
│
├── powershell/
│   └── profile.ps1                ← PS profile: prompt, aliases, helper functions
│
├── git/
│   └── .gitconfig                 ← aliases, colors, sensible defaults
│
├── windows-terminal/
│   └── settings.json              ← Catppuccin Mocha theme, Nerd Font, keybindings
│
├── vscode/
│   ├── settings.json              ← editor settings, font, theme
│   └── extensions.txt             ← extension list for auto-install
│
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

## 📦 Apps (via winget)

Key apps tracked in `apps/winget-packages.json`:

| Category | Apps |
|----------|------|
| **Dev** | Git, VS Code, PowerShell 7, Python |
| **Terminal** | Windows Terminal, Oh My Posh |
| **Media** | mpv, VLC, ShareX, Bandicut |
| **Utilities** | 7-Zip, Everything, Ditto, TeraCopy, Bulk Rename, dupeGuru |
| **Productivity** | Notion, Obsidian, LibreOffice |
| **Creative** | Adobe Creative Cloud (After Effects, Media Encoder) |
| **System** | MSI Afterburner, HWiNFO, CrystalDiskInfo, Macrium Reflect |
| **Gaming** | Steam, Lossless Scaling |
| **Privacy** | Proton VPN, KeePassXC |

---

## 💻 PowerShell Profile

Custom functions available after install:

| Command | Description |
|---------|-------------|
| `drives` | All drives with size and free space |
| `uptime` | Time since last boot |
| `sysinfo` | Quick hardware/OS snapshot |
| `users` | Local user accounts |
| `admins` | Local admin group members |
| `startup-list` | All startup entries |
| `startup-find 'pattern'` | Search startup entries by name/path |
| `tasks-user` | Non-Microsoft scheduled tasks |
| `pkillf name` | Force-kill processes matching name |
| `touch path` | Create empty file |
| `grep pattern` | Pipeline-friendly Select-String wrapper |
| `reload` | Re-source the profile |
| `dots` | `cd` to `~/dotfiles` |

**Navigation shortcuts:** `c` (C:\), `d` (D:\), `home`, `tools`, `psh`

---

## 🎨 Terminal Theme

Windows Terminal is configured with **Catppuccin Mocha** — matching the Oh My Posh theme.

Requires [CaskaydiaCove Nerd Font](https://www.nerdfonts.com/font-downloads) for icons in the prompt.
Install it and set it as the terminal font if icons look broken.

---

## 🖥️ Related

- **[mpv-config](https://github.com/hedglen/mpv-config)** — full mpv media player setup with HDR auto-switching, shaders, Scimitar buttons, and more
