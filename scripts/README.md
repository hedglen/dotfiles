# Scripts

Utility scripts for this workstation. The repo holds the small tools that do not belong in a single app repo but still need to be tracked, documented, and runnable from a clean machine.

## Layout

- `autohotkey/` for Windows automation helpers
- `powershell/` for PowerShell utilities
- `python/` for cross-platform CLI helpers
- `workstation-health.ps1` for a quick workstation integrity check
- media and transcription scripts at repo root for one-off operational tasks

## Workstation Health Check

Run this from PowerShell:

```powershell
pwsh -File "$HOME\workstation\dotfiles\scripts\workstation-health.ps1"
```

What it checks:

- canonical `$HOME\workstation` layout
- key Windows tools on `PATH`
- dry-run safety for `dotfiles/install.ps1`
- dry-run safety for `mpv-config/install.ps1` when present
- presence of important linked config files
- dirty git repos across the main workstation repos

For more detail:

```powershell
pwsh -File "$HOME\workstation\dotfiles\scripts\workstation-health.ps1" -Verbose
```

## Ollama File Helper

`python/ollama-files.py` lets you explicitly feed files to a local Ollama model and optionally apply edits back to disk.

Use it from WSL when possible. That is the most reliable path for this workstation.

### Ask About A File

```bash
python ~/workstation/dotfiles/scripts/python/ollama-files.py \
  --model qwen3:8b \
  --file README.md \
  ask "Summarize this file"
```

### Ask About Multiple Files

```bash
python ~/workstation/dotfiles/scripts/python/ollama-files.py \
  --model qwen2.5-coder:7b \
  --file app.py \
  --file utils.py \
  ask "What should be refactored first?"
```

### Include A Glob

```bash
python ~/workstation/dotfiles/scripts/python/ollama-files.py \
  --model qwen2.5-coder:7b \
  --glob "src/*.py" \
  ask "Find duplicated logic"
```

### Preview Edits Without Writing

```bash
python ~/workstation/dotfiles/scripts/python/ollama-files.py \
  --model qwen2.5-coder:7b \
  --file app.py \
  edit "Refactor this into smaller functions"
```

The script prints a unified diff and stops.

### Apply Edits

```bash
python ~/workstation/dotfiles/scripts/python/ollama-files.py \
  --model qwen2.5-coder:7b \
  --file app.py \
  edit --apply "Refactor this into smaller functions"
```

### Guardrails

- only files passed with `--file` or `--glob` are visible to the model
- files larger than `--max-bytes` are refused
- edits are dry-run by default
- `--apply` is required before any file is written
- on Windows, very large prompts are intentionally refused because WSL is more reliable for larger file sets

## Repo Hygiene

Generated Python cache files are ignored through `.gitignore`.

If you already have stale cache folders locally, remove them once:

```powershell
Remove-Item -Recurse -Force "$HOME\workstation\dotfiles\scripts\python\__pycache__"
```
