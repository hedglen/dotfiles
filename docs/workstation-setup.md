# Workstation setup (runbook)

Command center for **rebuild, verify, and maintain** the workstation environment.

## Canonical rules (do not drift)

- **Canonical root**: `C:\Users\rjh\workstation\`
- **Dotfiles is the source of truth** for installed apps and hotkey targets: `dotfiles/apps/winget-packages.json`, `dotfiles/apps/scoop-packages.json`, plus `apps/winget-packages.md` / `apps/scoop-packages.md`. This runbook, **`dotfiles/docs/`**, and AutoHotkey should agree with those lists; anything not in a manifest is **optional / manual** — say so in prose.
- **Prefer relative paths** in docs (e.g. `dotfiles/`, `tools/`). For Python helpers, source of truth is **`dotfiles/projects/`**; **`workstation\projects`** is usually a **junction** to that folder.
- **Absolute paths** only when clarity needs it; they must use the canonical root.
- **Compatibility only**: `%USERPROFILE%\tools` may be a **junction** → `C:\Users\rjh\workstation\tools`. Do not use it in new work except when explaining compatibility.

## Workspace layout (canonical)

```text
workstation/
│
├── rjh-workspace.code-workspace   (command center)
├── WORKSTATION-SETUP.md           (stub → dotfiles/docs/workstation-setup.md)
│
├── dotfiles/                      (configs + docs + notes + scripts + bundled projects)
│   ├── docs/                      guides: workstation-setup, layout, tools, directory-opus
│   ├── notes/                     (personal markdown)
│   ├── scripts/                   (automation + utilities; see dotfiles/scripts/README.md)
│   ├── projects/                  (media-organizer, ytdl - Python venvs from install.ps1)
│   └── mpv-config/                mpv Lua/conf bundle; junction → tools\mpv\portable_config
├── tools/                         (portable tools / utilities)
├── projects/                      (junction → dotfiles\projects when install.ps1 created it)
└── hedglen-profile/               (GitHub profile)

```

**Also:** `workstation\scripts` is normally a **junction** → `dotfiles\scripts` (same installer pattern).

## Fresh machine bootstrap

From PowerShell (Git required first):

```powershell
irm https://raw.githubusercontent.com/hedglen/dotfiles/master/install.ps1 | iex
```

This clones and configures the workspace:

1. `dotfiles` → `workstation/dotfiles`
2. `hedglen-profile` → workspace dir; **`workstation\tools`** created if missing. Junctions **`workstation\scripts`** → **`dotfiles\scripts`** and **`workstation\projects`** → **`dotfiles\projects`** when those paths are unused. Utility scripts: **`dotfiles/scripts/`**. Personal notes: **`dotfiles/notes/`**.
3. Apps via winget + Scoop (`dotfiles/apps/winget-packages.json` and `scoop-packages.json`; use **`-NoScoop`** to skip Scoop only).
4. Python **`.venv`** setup for **`dotfiles\projects\media-organizer`** and **`dotfiles\projects\ytdl`** (needs **`py`** on PATH; skip with **`-NoPythonProjects`** or **`-ConfigsOnly`**).
5. Windows tweaks (admin required)
6. Config symlinks, VS Code extensions, fonts, mpv config, AutoHotkey
   - **mpv:** junction **`tools\mpv\portable_config`** → **`dotfiles\mpv-config`** (when `install.ps1` sets it up)
   - **yt-dlp global CLI:** `dotfiles/projects/ytdl/appdata-config` → `%APPDATA%\yt-dlp\config` (same as [workstation-tools.md](workstation-tools.md))

**Python helpers:** venvs are created by **`install.ps1`** by default. To **repair** manually (e.g. after a bad upgrade):

```powershell
Set-Location "$HOME\workstation\dotfiles\projects\media-organizer"
py -3 -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt

Set-Location "$HOME\workstation\dotfiles\projects\ytdl"
py -3 -m venv .venv
.\.venv\Scripts\pip install rich
```

If **`workstation\projects`** is a junction, `Set-Location "$HOME\workstation\projects\media-organizer"` is equivalent.

---

## Quick start

### Open the workspace

```powershell
code "C:\Users\rjh\workstation\rjh-workspace.code-workspace"
```

### Typical working directories

```powershell
Set-Location "C:\Users\rjh\workstation"
Set-Location "C:\Users\rjh\workstation\dotfiles"
Set-Location "C:\Users\rjh\workstation\projects"   # junction → dotfiles\projects when installer set it up
```

## Compatibility junctions

```text
%USERPROFILE%\tools             →  workstation\tools
workstation\scripts             →  dotfiles\scripts    (when created by install.ps1)
workstation\projects            →  dotfiles\projects   (when created by install.ps1)
```

If a doc or script mentions **`%USERPROFILE%\tools`** only, treat it as **compat** for the tools folder.

## Verification checklist

### Workspace health

- Open `rjh-workspace.code-workspace` and confirm all folders resolve.

### Fast health check (recommended)

```powershell
Set-Location "C:\Users\rjh\workstation"
.\dotfiles\scripts\workstation-health.ps1
```

Verbose:

```powershell
.\dotfiles\scripts\workstation-health.ps1 -Verbose
```

### Junction health

- Confirm `%USERPROFILE%\tools` resolves into `workstation\tools` (if you use that junction).
- Optionally confirm **`workstation\scripts`** and **`workstation\projects`** point at **`dotfiles\scripts`** and **`dotfiles\projects`**.

### Dry-run installers

```powershell
Set-Location "C:\Users\rjh\workstation\dotfiles"
.\install.ps1 -DryRun

Set-Location "C:\Users\rjh\workstation\dotfiles\mpv-config"
.\install.ps1 -DryRun
```

---

**Last updated:** 2026-04-06

