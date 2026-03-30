## WSL Shell Files

This folder tracks the Linux-side shell setup used by the WezTerm `wsl`, `claude`, `codex`, and `ollama` tabs.

Tracked files:

- `.zshrc`
- `.p10k.zsh`

Live targets inside WSL:

- `/home/rjh/.zshrc`
- `/home/rjh/.p10k.zsh`

### What The Tracked `.zshrc` Does

- loads `oh-my-zsh`
- uses `powerlevel10k`
- adds `$HOME/.local/bin` to `PATH` so user installs like `uv` work
- defines `WORKSTATION` from the Windows user profile path
- provides workstation launch helpers for `claude` and `codex`
- provides Ollama shortcuts:
  - `oc` → `qwen2.5-coder:7b`
  - `og` → `qwen3:8b`
  - `ov` → `gemma3:4b`
- adds `fd` as an alias for Ubuntu's `fdfind`
- initializes `zoxide` if installed
- sets `BROWSER=wslview` when `wslu` is installed so browser-based flows from WSL open correctly in Windows

### Keep Tracked And Live Files In Sync

Edit the tracked files first, then copy them into WSL.

If your Windows username is not `rjh`, replace `/mnt/c/Users/rjh` with your own Windows home mount.

From PowerShell:

```powershell
wsl -e zsh -lc 'cp /mnt/c/Users/rjh/workstation/dotfiles/wsl/.zshrc ~/.zshrc'
wsl -e zsh -lc 'cp /mnt/c/Users/rjh/workstation/dotfiles/wsl/.p10k.zsh ~/.p10k.zsh'
```

From WSL:

```bash
cp /mnt/c/Users/rjh/workstation/dotfiles/wsl/.zshrc ~/.zshrc
cp /mnt/c/Users/rjh/workstation/dotfiles/wsl/.p10k.zsh ~/.p10k.zsh
exec zsh -l
```

### Recommended WSL Tooling

Install the tools this shell config expects:

```bash
sudo apt update
sudo apt install -y ripgrep fd-find fzf jq tmux btop ncdu gh neovim pipx zoxide wslu
curl -LsSf https://astral.sh/uv/install.sh | sh
exec zsh -l
```

### GitHub CLI From WSL

`gh auth login` works best when `wslu` is installed, because that provides `wslview`.

Verify:

```bash
command -v wslview
echo "$BROWSER"
```

Then log in:

```bash
gh auth login
```

Recommended answers:

- account: `GitHub.com`
- protocol: `HTTPS`
- authenticate git with GitHub credentials: `Yes`
- auth method: `Login with a web browser`

If the browser flow fails, go directly to [github.com/login/device](https://github.com/login/device) in Windows and enter the one-time code shown by `gh`.

### Prompt Notes

The prompt itself lives in `.p10k.zsh`.

This workstation uses the classic Powerlevel10k layout with:

- user and host on the left
- full working directory
- git branch/status
- command status, timing, and clock on the right

If you change the prompt, update both the live WSL file and the tracked copy here.
