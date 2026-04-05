# Workstation setup (runbook)

Command center for **rebuild, verify, and maintain** the workstation environment.

## Canonical rules (do not drift)

- **Canonical root**: `C:\Users\rjh\workstation\`
- **Dotfiles is the source of truth** for installed apps and hotkey targets: `dotfiles/apps/winget-packages.json`, `dotfiles/apps/scoop-packages.json`, plus `apps/winget-packages.md` / `apps/scoop-packages.md`. This runbook, **`dotfiles/docs/`**, and AutoHotkey should agree with those lists; anything not in a manifest is **optional / manual** — say so in prose.
- **Prefer relative paths** in docs (e.g. `dotfiles/`, `tools/`, `projects/`).
- **Absolute paths** only when clarity needs it; they must use the canonical root.
- **Compatibility only**: `%USERPROFILE%\tools` may be a **junction** → `C:\Users\rjh\workstation\tools`. Do not use it in new work except when explaining compatibility.

## Workspace layout (canonical)

```text
workstation/
│
├── rjh-workspace.code-workspace   (command center)
├── WORKSTATION-SETUP.md           (stub → dotfiles/docs/workstation-setup.md)
│
├── dotfiles/                      (configs + docs/ + notes/)
│   ├── docs/                      guides: workstation-setup, layout, tools, directory-opus
│   ├── notes/                     (personal markdown)
│   └── scripts/                   (automation + utilities; see dotfiles/scripts/README.md)
├── tools/                         (portable tools / utilities)
├── projects/                      (active projects)
├── hedglen-profile/               (GitHub profile)
└── mpv-config/                    (mpv configuration repo)
```

## Fresh machine bootstrap

From PowerShell (Git required first):

```powershell
irm https://raw.githubusercontent.com/hedglen/dotfiles/master/install.ps1 | iex
```

This clones and configures the workspace:

1. `dotfiles` → `workstation/dotfiles`
2. `hedglen-profile` → workspace dir (utility scripts live under `dotfiles/scripts/`; personal notes live under `dotfiles/notes/`)
3. Apps via winget + Scoop (`dotfiles/apps/winget-packages.json` and `scoop-packages.json`; `install.ps1` installs Scoop from get.scoop.sh when needed)
4. Windows tweaks (admin required)
5. Config symlinks, VS Code extensions, fonts, mpv config, AutoHotkey

**After bootstrap**, set up project venvs manually:

```powershell
cd workstation\projects\media-organizer && python -m venv .venv && .venv\Scripts\pip install -r requirements.txt
cd workstation\projects\ytdl           && python -m venv .venv && .venv\Scripts\pip install rich
```

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
Set-Location "C:\Users\rjh\workstation\projects"
```

## Compatibility junctions

```text
%USERPROFILE%\tools  →  C:\Users\rjh\workstation\tools
```

If a doc or script mentions `%USERPROFILE%\tools`, treat it as **compat only**.

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

- Confirm `%USERPROFILE%\tools` resolves into `workstation\tools`.

### Dry-run installers

```powershell
Set-Location "C:\Users\rjh\workstation\dotfiles"
.\install.ps1 -DryRun

Set-Location "C:\Users\rjh\workstation\mpv-config"
.\install.ps1 -DryRun
```

---

**Last updated:** 2026-04-06
