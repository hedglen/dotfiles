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
3. Symlink all configs to their correct locations
4. Install all VS Code extensions
5. Clone the mpv config

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
│   └── settings.json              ← Neon Blaze theme, Nerd Font, keybindings
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
| **Dev** | Git, VS Code, PowerShell 7, Python Launcher |
| **Terminal** | Windows Terminal |
| **Media** | VLC, MPC-BE, PotPlayer, ShareX, Bandicut, yt-dlp |
| **Utilities** | 7-Zip, NanaZip, Everything, Ditto, TeraCopy, Bulk Rename, dupeGuru, TreeSize, File Pilot |
| **Productivity** | Notion, Obsidian, LibreOffice, Flow Launcher, Zoom |
| **Creative** | Adobe Creative Cloud, Adobe Acrobat |
| **System** | MSI Afterburner, HWiNFO, CrystalDiskInfo, FanControl, AOMEI Partition Assistant |
| **Gaming** | Steam |
| **Privacy** | Proton VPN, Proton Drive, Proton Pass, Proton Authenticator, Bitwarden, Signal |
| **Cloud** | Google Drive, pCloud Drive |
| **Package Mgmt** | UniGetUI |
| **Downloads** | IDM, JDownloader 2 (see Manual Installs) |

---

## 🔧 Manual Installs

These apps are **not available in winget** and must be installed manually after running `install.ps1`.

---

### 🔵 JDownloader 2
- **Download:** https://jdownloader.org/download/index
- **Install:** Run the installer, sign into your My JDownloader account if you use remote access
- **Account:** hedglen@pm.me

---

### 🟢 Macrium Reflect Home
- **Download:** https://www.macrium.com/reflectfree
- **Install:** Run installer, select "Home" edition (free)
- **Note:** Re-register email after install to unlock scheduling features

---

### 🟠 Battle.net
- **Download:** https://us.battle.net/download/getBnetInstaller
- **Install:** Run Battle.net installer, log in with Blizzard account
- **Account:** stored in Bitwarden

---

## 🔑 Licenses & Accounts

> ⚠️ **Keys are NOT stored here.** This is a public repo.
> All license keys and passwords are stored in **Bitwarden** under the vault folder `🖥️ Software Licenses`.

| App | Type | Where to Find Key |
|-----|------|-------------------|
| **StartAllBack** | Paid license | Bitwarden → Software Licenses |
| **Internet Download Manager** | Paid license | Bitwarden → Software Licenses |
| **Adobe Creative Cloud** | Subscription | Bitwarden → Adobe |
| **Corsair iCUE** | Free (account optional) | hedglen@pm.me |
| **Proton** (VPN/Drive/Pass/Auth) | Subscription | Bitwarden → Proton |
| **Bitwarden** | Account | Master password — memorize it |
| **JDownloader 2** | Free (account optional) | Bitwarden → JDownloader |
| **Battle.net / Blizzard** | Account | Bitwarden → Blizzard |
| **Steam** | Account | Bitwarden → Steam |

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
| `save-dots` | Commit & push all dotfile changes to GitHub |

**Navigation shortcuts:** `c` (C:\\), `d` (D:\\), `home`, `tools`, `psh`

---

## 🎨 Terminal Theme

Windows Terminal is configured with **Neon Blaze** — a custom dark theme with neon accents.

| Element | Color |
|---------|-------|
| Prompt tag `[USER]` | Neon green |
| `PS` label | Neon purple |
| Current path | Neon orange |
| Background | Near-black `#0A0A0F` |

Requires [CaskaydiaCove Nerd Font](https://www.nerdfonts.com/font-downloads).
Download and install it, then it will be picked up automatically by the Terminal config.

---

## 🖥️ Related

- **[mpv-config](https://github.com/hedglen/mpv-config)** — full mpv media player setup with HDR auto-switching, shaders, Scimitar buttons, favorites, audio normalize, and more
