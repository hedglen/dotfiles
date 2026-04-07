#!/usr/bin/env bash
# WSL tab right pane — printed once, then drops into zsh. Spawned via wezterm.lua wsl_helper_spawn().
cd "$HOME" || exit 1
clear
_win_profile_raw=$(powershell.exe -NoProfile -Command "[Environment]::GetFolderPath('UserProfile')" 2>/dev/null | tr -d '\r')
_win_profile_raw=${_win_profile_raw//$'\r'/}
if [ -z "$_win_profile_raw" ]; then
  _win_profile_raw=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
  _win_profile_raw=${_win_profile_raw//$'\r'/}
fi
_win_base=""
if [ -n "$_win_profile_raw" ]; then
  if command -v wslpath >/dev/null 2>&1; then
    _win_base=$(wslpath -u "$_win_profile_raw" 2>/dev/null)
  fi
  if [ -z "$_win_base" ] && [[ "$_win_profile_raw" =~ ^([A-Za-z]):\\(.*)$ ]]; then
    _dr="${BASH_REMATCH[1],,}"
    _rest="${BASH_REMATCH[2]//\\//}"
    _win_base="/mnt/${_dr}/${_rest}"
  fi
fi
_win_ws=""
_win_ws_warn=""
if [ -n "$_win_base" ]; then
  _win_ws="${_win_base}/workstation"
fi
if [ -z "$_win_ws" ]; then
  _win_ws="/mnt/c/Users/${USER}/workstation"
  _win_ws_warn="1"
fi
_win_projects="${_win_ws}/dotfiles/projects"
_win_dotfiles="${_win_ws}/dotfiles"
_win_scripts="${_win_ws}/dotfiles/scripts"
printf "\033[35mWSL Helper\033[0m\n\n"
if [ -n "$_win_ws_warn" ]; then
  printf "\033[33mMount paths: could not read Windows profile; guess %s\033[0m\n\n" "$_win_ws"
fi
printf "\033[36mDistro:\033[0m  %s\n" "${WSL_DISTRO_NAME:-Ubuntu}"
printf "\033[36mKernel:\033[0m  %s\n" "$(uname -r)"
if command -v zsh >/dev/null 2>&1; then
  printf "\033[36mShell:\033[0m   %s\n" "$(command -v zsh)"
else
  printf "\033[36mShell:\033[0m   %s\n" "$(command -v bash)"
fi
printf "\033[36mHome:\033[0m    %s\n" "$HOME"
printf "\033[36mMount:\033[0m   %s\n" "$_win_ws"
printf "\n\033[36mQuick jump:\033[0m\n"
printf "  cd ~\n"
printf "  cd %s\n" "$_win_ws"
printf "  cd %s\n" "$_win_projects"
printf "  cd %s\n" "$_win_dotfiles"
printf "  cd %s\n" "$_win_scripts"
printf "\n\033[36mLabels:\033[0m\n"
printf "  workstation -> %s\n" "$_win_ws"
printf "  projects    -> %s\n" "$_win_projects"
printf "  dotfiles    -> %s\n" "$_win_dotfiles"
printf "  scripts     -> %s\n" "$_win_scripts"
printf "\n\033[36mTooling:\033[0m\n"
if command -v git >/dev/null 2>&1; then printf "  git:     %s\n" "$(git --version | sed 's/git version //')"; else printf "  git:     missing\n"; fi
if command -v node >/dev/null 2>&1; then printf "  node:    %s\n" "$(node -v)"; else printf "  node:    missing\n"; fi
if command -v python3 >/dev/null 2>&1; then printf "  python3: %s\n" "$(python3 --version 2>&1 | sed 's/Python //')"; else printf "  python3: missing\n"; fi
printf "\n\033[36mGitHub CLI (gh):\033[0m\n"
if command -v wslview >/dev/null 2>&1; then
  printf "\033[90m  wslview ready (optional browser for gh auth login)\033[0m\n"
else
  printf "\033[90m  install wslu (wslview) for browser auth, or paste PAT\033[0m\n"
fi
printf "\033[90m  token if browser says slow_down\033[0m\n"
printf "\033[33m  gh auth status\033[0m\n"
printf "\033[90m  gh auth login   HTTPS, paste PAT\033[0m\n"
printf "\033[90m  PAT scopes: repo + read:org + workflow\033[0m\n"
printf "\033[33m  gh auth setup-git   git HTTPS uses gh creds\033[0m\n"
printf "\033[33m  gh repo clone owner/repo\033[0m\n"
printf "\033[90m  gh pr list | create | view <n>\033[0m\n"
printf "\033[90m  gh issue list | create\033[0m\n"
printf "\033[33m  gh browse\033[0m\n"
printf "\n"
if command -v zsh >/dev/null 2>&1; then
  exec zsh -il
fi
exec bash -il
