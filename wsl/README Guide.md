# WSL Setup Guide

Personal reference for setting up and using WSL on my NZXT workstation.

## Initial Setup

Ubuntu 24.04 LTS was installed via Windows. Shell is zsh with Oh My Posh already configured.

### Update and install core tools

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget ffmpeg python3 python3-pip nodejs npm jq htop neofetch
```

### yt-dlp

```bash
pip3 install --break-system-packages yt-dlp
```

Add local bin to PATH (pip installs here):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Git identity

```bash
git config --global user.name "Rob Hedglen"
git config --global user.email "YOUR_GITHUB_EMAIL"
```

### SSH key for GitHub

```bash
ssh-keygen -t ed25519 -C "YOUR_GITHUB_EMAIL"
cat ~/.ssh/id_ed25519.pub
```

Copy the output, go to [github.com/settings/keys](https://github.com/settings/keys), click **New SSH key**, title it `WSL Ubuntu`, paste the key.

Test:

```bash
ssh -T git@github.com
```

---

## Aliases

### dl (yt-dlp wrapper)

Downloads best quality video + audio to the Windows media folder. Uses Chrome cookies for YouTube authentication.

**Note:** Chrome encrypts cookies with Windows DPAPI, so WSL can't read them while Chrome is running. For YouTube downloads, use the PowerShell `dl` function instead. This alias works for non-YouTube sites that don't need cookies.

```bash
alias dl='yt-dlp -o "/mnt/d/Media/Downloads/%(title)s.%(ext)s"'
```

---

## Key Paths

| What | Path |
|------|------|
| WSL home | `/home/rjh` |
| Windows home | `/mnt/c/Users/rjh` |
| Workstation folder | `/mnt/c/Users/rjh/workstation` |
| Dotfiles | `/mnt/c/Users/rjh/workstation/projects/dotfiles` |
| Music library | `/mnt/d/Media/Music` |
| Downloads | `/mnt/d/Media/Downloads` |
| zsh config | `~/.zshrc` |

---

## What WSL Is Good For

### Claude Code

Claude Code runs natively in Linux. WSL is the recommended way to use it on Windows. Install with:

```bash
claude install
```

Then run with `claude` from any project directory.

### Bash scripting

Universal scripting language. Anything found online for automation, file processing, or media workflows will be in bash and runs directly here without translation to PowerShell.

### Bulk file operations

Unix tools for mass file work:

```bash
# Find all FLAC files over 100MB
find /mnt/d/Media/Music -name "*.flac" -size +100M

# Rename files (remove spaces)
rename 's/ /_/g' *.mp4

# Find duplicate files by checksum
find . -type f -exec md5sum {} + | sort | uniq -d -w32

# Strip EXIF metadata from all images in a folder
exiftool -all= *.jpg
```

Install extras: `sudo apt install -y rename exiftool imagemagick`

### ffmpeg workflows

Complex media processing chains in bash:

```bash
# Extract audio from video as FLAC
ffmpeg -i input.mp4 -vn -c:a flac output.flac

# Batch convert all WAV to FLAC
for f in *.wav; do ffmpeg -i "$f" -c:a flac "${f%.wav}.flac"; done

# Trim video (start at 1:30, duration 45 seconds)
ffmpeg -i input.mp4 -ss 00:01:30 -t 45 -c copy output.mp4

# Combine audio and video
ffmpeg -i video.mp4 -i audio.flac -c:v copy -c:a aac output.mp4
```

### SSH

Native SSH client for remote access:

```bash
# Connect to a server
ssh user@hostname

# Generate a key for a specific server
ssh-keygen -t ed25519 -f ~/.ssh/myserver

# Copy public key to server
ssh-copy-id user@hostname
```

Useful for home servers, NAS, Raspberry Pi, VPS.

### Learning Linux

WSL is a zero-risk sandbox. Break things, reinstall with `wsl --unregister Ubuntu` and `wsl --install -d Ubuntu` from PowerShell. Nothing on Windows is affected.

---

## PowerShell vs WSL — When to Use Which

| Task | Use |
|------|-----|
| YouTube downloads | PowerShell (cookies work) |
| winget / Windows apps | PowerShell |
| dotfiles management | PowerShell (source of truth is Windows side) |
| Claude Code | WSL |
| Bash scripts from the internet | WSL |
| Bulk file rename / find / process | WSL |
| ffmpeg batch jobs | Either (WSL is slightly easier to chain) |
| SSH into servers | WSL |
| Git push/pull | Either (both have SSH keys) |

---

## Troubleshooting

### pip not found

```bash
sudo apt install -y python3-pip
```

### Command installed but not found

Probably in `~/.local/bin`. Make sure PATH is set:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### zsh glob errors with %

Zsh interprets `%` as glob patterns. Wrap paths with `%(` in proper quotes or escape them.

### Permission denied on Windows files

Close the Windows app that has the file locked, or copy the file to `/tmp/` first.

### Reset WSL completely

From PowerShell:

```powershell
wsl --unregister Ubuntu
wsl --install -d Ubuntu
```

This wipes the Linux side. Windows files are untouched.
