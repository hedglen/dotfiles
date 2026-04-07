# Workstation layout (overview)

Canonical root pattern: **`$HOME\workstation\`** (author example on this machine: `C:\Users\rjh\workstation\`).

## Folder layout

```text
workstation/
├── rjh-workspace.code-workspace   (command center)
├── WORKSTATION-SETUP.md           (stub → dotfiles/docs/workstation-setup.md)
│
├── dotfiles/                      (single repo: config + docs + notes + scripts + Python projects)
│   ├── docs/                      guides and runbook (this tree)
│   ├── notes/                     personal markdown
│   ├── scripts/                   automation + utilities (workstation-health, transcribe, ...)
│   ├── projects/                  media-organizer, ytdl (.venv from install.ps1)
│   └── mpv-config/                mpv Lua/conf bundle; install.ps1 junction → tools\mpv\portable_config
├── tools/                         (portable tools / utilities, canonical)
│   ├── mpv/                       (canonical mpv binary location)
│   └── powershell/                (portable/pinned PS utilities)
│
├── scripts/                       (junction → dotfiles\scripts, if install.ps1 created it)
├── projects/                      (junction → dotfiles\projects, if install.ps1 created it)
└── hedglen-profile/               (GitHub profile README)
```

## Rules (no drift)

- **Canonical root**: `$HOME\workstation\`
- **Prefer relative paths** inside docs and scripts where possible.
- **Portable tools**: `$HOME\workstation\tools\`
- **mpv**: binary at **`tools\mpv\`**, config in **`dotfiles\mpv-config\`**; **`install.ps1`** creates a junction from **`tools\mpv\portable_config`** to that folder when appropriate.
- **Python helpers** (`orgmed`, `ytdl`): live under **`dotfiles\projects\`**; profile and installer use that path. **`workstation\projects`** is for convenience when the junction exists.

## Compatibility (legacy paths)

```text
C:\Users\rjh\tools  →  C:\Users\rjh\workstation\tools
```

Treat `%USERPROFILE%\tools` as **compatibility only**. New work should use the canonical workstation paths.

## Next

- Runbook: [**workstation-setup.md**](workstation-setup.md)
- Quick health check: `.\dotfiles\scripts\workstation-health.ps1` from `$HOME\workstation`
