# Workstation layout (overview)

Canonical root for the hedglen setup on this machine: **`C:\Users\rjh\workstation\`**.

## Folder layout

```text
workstation/
├── rjh-workspace.code-workspace   (command center)
├── WORKSTATION-SETUP.md           (stub → dotfiles/docs/workstation-setup.md)
│
├── dotfiles/                      (configs, documentation, personal notes)
│   ├── docs/                      … this folder (guides and runbook)
│   ├── notes/                     (personal markdown)
│   └── scripts/                   (automation + utilities)
├── tools/                         (portable tools / utilities, canonical)
│   ├── mpv/                       (canonical mpv binary location)
│   └── powershell/                (portable/pinned PS utilities)
│
├── projects/                      (active coding / repos)
├── hedglen-profile/               (GitHub profile README)
└── mpv-config/                    (mpv configuration repo)
```

## Rules (no drift)

- **Canonical root**: `C:\Users\rjh\workstation\`
- **Prefer relative paths** inside docs and scripts where possible.
- **Portable tools**: `C:\Users\rjh\workstation\tools\`
- **mpv**: `C:\Users\rjh\workstation\tools\mpv\`

## Compatibility (legacy paths)

```text
C:\Users\rjh\tools  →  C:\Users\rjh\workstation\tools
```

Treat `C:\Users\rjh\tools` as **compatibility only**. New work should use the canonical workstation paths.

## Next

- Runbook: [**workstation-setup.md**](workstation-setup.md)
- Quick health check: `.\dotfiles\scripts\workstation-health.ps1` from `C:\Users\rjh\workstation`
