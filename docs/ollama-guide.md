# Ollama Guide

Practical reference for running local models on this workstation from WSL and the custom WezTerm dashboard.

**Location:** this file is **`dotfiles/docs/ollama-guide.md`** (same repo as `install.ps1`).

Current machine:

- Windows 11 host
- Ubuntu on WSL2
- NVIDIA GeForce RTX 3070 Ti Founders Edition
- 8 GB VRAM
- Ollama running in WSL as a `systemd` service

The default recommendation for this workstation is:

- run Ollama inside WSL
- keep coding workflows in WSL too
- use the dedicated WezTerm `ollama` tab for day-to-day sessions
- avoid running a second Windows Ollama server unless a Windows-native app truly needs it

---

## Why WSL First

WSL is the cleanest local AI path for this machine because:

- the repos already live there through the `/mnt/c/.../workstation` mount
- Linux shell tooling is easier to script against
- the WezTerm dashboard is already wired around WSL
- it avoids split-brain Windows-vs-WSL Ollama installs

Use the Windows Ollama install only when a Windows-native app specifically needs a local endpoint.

---

## Install In WSL

Open Ubuntu in WSL and install prerequisites:

```bash
sudo apt update
sudo apt install -y zstd
```

Install Ollama:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Verify:

```bash
ollama --version
systemctl status ollama --no-pager
nvidia-smi
```

If `ollama serve` says `address already in use`, that usually means the background `ollama.service` is already running, which is the expected setup here.

---

## Current Local State

Verified on March 30, 2026:

- Ollama version: `0.19.0`
- service: `ollama.service`
- installed models:
  - `gemma3:4b`
  - `qwen3:8b`
  - `qwen2.5-coder:7b`
  - `qwen2.5-coder:latest`
  - `llama3.2:latest`

Check the live state any time with:

```bash
ollama list
ollama ps
```

---

## Shell Shortcuts

WSL `zsh` aliases on this workstation:

- `oc` = `ollama run qwen2.5-coder:7b`
- `og` = `ollama run qwen3:8b`
- `ov` = `ollama run gemma3:4b`

From a normal shell prompt:

```bash
oc
og
ov
```

If the model is not downloaded yet, Ollama will pull it automatically the first time you run the alias.

---

## WezTerm Ollama Tab

The `ollama` tab is designed as a three-pane cockpit:

- left pane: main model session
- upper-right pane: live Ollama helper
- lower-right pane: normal WSL shell

The helper refreshes every 3 seconds and shows:

- last refresh time
- service status
- GPU detection
- loaded models
- installed models
- hot pink highlighting when the active model is also installed

### Important Prompt Rule

- `>>>` means you are inside a model chat
- a shell prompt means you can run commands like `oc`, `og`, or `ov`

That matters because typing `oc` at `>>>` asks the current model about the text `oc`; it does not switch models.

### Switching Models In The Left Pane

1. Exit the current chat with `Ctrl+D` or `/bye`
2. Wait until the left pane is back at a shell prompt
3. Run the model you want:

```bash
oc
og
ov
```

The left pane now starts in `qwen2.5-coder:7b` automatically, but when you exit the chat it stays open as a shell so the tab layout does not collapse.

### Why The Bottom-Right Shell Exists

The lower-right pane is always a shell. Use it when you want to:

- start another model without interrupting the main chat
- run `ollama ps`
- inspect `journalctl -u ollama -f`
- pull or remove models

---

## Day-To-Day Commands

List installed models:

```bash
ollama list
```

Show currently loaded models:

```bash
ollama ps
```

Pull a model:

```bash
ollama pull qwen2.5-coder:7b
```

Run a model directly:

```bash
ollama run qwen3:8b
```

Remove a model:

```bash
ollama rm qwen2.5-coder:7b
```

Follow service logs:

```bash
journalctl -u ollama -f
```

Restart the service:

```bash
sudo systemctl restart ollama
```

---

## Recommended Models For This GPU

The RTX 3070 Ti with 8 GB VRAM is a strong fit for efficient local models in the 4B to 8B range.

Recommended set:

| Model | Use | Why it fits this machine |
| --- | --- | --- |
| `qwen2.5-coder:7b` | coding | best first coding pick for local repo help |
| `qwen3:8b` | general chat and reasoning | good everyday default |
| `gemma3:4b` | lightweight text or multimodal experiments | smaller and easy on VRAM |
| `llama3.2:latest` | fallback | small and fast |

Skip heavier local models first:

- `qwen3:30b`
- `qwen2.5-coder:32b`
- `qwen3-vl:30b`
- `mistral-small`
- `devstral`

Those may run, but they are not the sweet spot for this GPU if you want responsive local use.

---

## File-Aware Wrapper

If you want Ollama to work on real files without pasting them manually, use the file-aware wrapper in **dotfiles** (from WSL, adjust the mount path if your Windows username differs):

```bash
python ~/workstation/dotfiles/scripts/python/ollama-files.py \
  --model qwen3:8b \
  --file README.md \
  ask "Summarize this file"
```

Preview edits without writing:

```bash
python ~/workstation/dotfiles/scripts/python/ollama-files.py \
  --model qwen2.5-coder:7b \
  --file app.py \
  edit "Refactor this into smaller functions"
```

Apply edits back to disk:

```bash
python ~/workstation/dotfiles/scripts/python/ollama-files.py \
  --model qwen2.5-coder:7b \
  --file app.py \
  edit --apply "Refactor this into smaller functions"
```

If **`workstation/scripts`** is a junction to **`dotfiles/scripts`**, you can use **`~/workstation/scripts/python/ollama-files.py`** instead.

Guardrails:

- only files you pass with `--file` or `--glob` are visible to the model
- edits are dry-run by default
- `--apply` is required before anything is written
- WSL is the preferred runtime on this machine, especially for larger prompts

---

## Troubleshooting

If `ollama` is not found in WSL:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

If GPU acceleration seems missing:

- run `nvidia-smi`
- restart the service with `sudo systemctl restart ollama`
- check the helper pane to see whether the active model row shows GPU use

If a shell command behaves strangely after `ollama run ...`:

- look at the prompt
- `>>>` means you are still inside chat
- exit with `Ctrl+D` or `/bye`
- rerun the shell command from a normal prompt

If the helper shows no active model:

- that can be normal when no chat is running
- check `ollama ps` from the bottom-right shell pane

If the helper ever looks stale:

- reopen the `ollama` tab
- the current helper is live-refreshing, not a one-shot snapshot

---

## Quick Start

If you just want the short version:

```bash
og
```

Then:

- ask your question in the left pane
- use `Ctrl+D` when you want to get back to a shell
- switch models with `oc`, `og`, or `ov`
