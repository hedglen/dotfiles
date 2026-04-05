#!/usr/bin/env bash

cd "$HOME" || exit 1

render() {
  clear
  printf "\033[35mOllama Helper\033[0m\n\n"
  _active_installed_match=0

  _refresh_ts="$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date)"
  printf "\033[36mLast refresh:\033[0m %s\n" "$_refresh_ts"

  if command -v ollama >/dev/null 2>&1; then
    printf "\033[36mVersion:\033[0m %s\n" "$(ollama --version 2>/dev/null | sed 's/^ollama version is //')"
  else
    printf "\033[36mVersion:\033[0m missing\n"
  fi

  if command -v systemctl >/dev/null 2>&1; then
    _service_state="$(systemctl is-active ollama 2>/dev/null || printf 'unknown')"
    if [ "$_service_state" = "active" ]; then
      printf "\033[36mService:\033[0m \033[32m%s\033[0m\n" "$_service_state"
    else
      printf "\033[36mService:\033[0m \033[31m%s\033[0m\n" "$_service_state"
    fi
  else
    printf "\033[36mService:\033[0m systemctl unavailable\n"
  fi

  if command -v nvidia-smi >/dev/null 2>&1; then
    _gpu_line="$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null | head -n 1)"
    if [ -n "$_gpu_line" ]; then
      printf "\033[36mGPU:\033[0m     %s\n" "$_gpu_line"
    else
      printf "\033[36mGPU:\033[0m     detected but unavailable\n"
    fi
  else
    printf "\033[36mGPU:\033[0m     nvidia-smi missing\n"
  fi

  printf "\n\033[36mShortcuts:\033[0m\n"
  printf "  oc  OpenClaw\n"
  printf "  qc  qwen2.5-coder:7b\n"
  printf "  og  qwen3:8b\n"
  printf "  ov  gemma3:4b\n"

  printf "\n\033[36mLoaded models:\033[0m\n"
  if command -v ollama >/dev/null 2>&1; then
    _ps_output="$(ollama ps 2>/dev/null)"
    _ps_rows="$(printf '%s\n' "$_ps_output" | sed '/^NAME[[:space:]]/d;/^[[:space:]]*$/d')"
    if [ -n "$_ps_rows" ]; then
      _active_names="$(printf '%s\n' "$_ps_rows" | awk '{print $1}')"
      if printf '%s\n' "$_ps_rows" | grep -Eq 'GPU|[0-9]+%/[0-9]+%'; then
        printf "\033[1;95m  active now (GPU in use)\033[0m\n"
      else
        printf "\033[32m  active now\033[0m\n"
      fi
      _ps_header="$(printf '%s\n' "$_ps_output" | sed -n '1p')"
      printf "%s\n" "$_ps_header"
      while IFS= read -r _ps_line; do
        if printf '%s\n' "$_ps_line" | grep -Eq 'GPU|[0-9]+%/[0-9]+%'; then
          printf "\033[1;95m%s\033[0m\n" "$_ps_line"
        else
          printf "%s\n" "$_ps_line"
        fi
      done <<EOF
$(printf '%s\n' "$_ps_rows")
EOF
    elif [ -n "$_ps_output" ]; then
      printf "\033[2;36m  idle (no active models)\033[0m\n"
      printf "%s\n" "$_ps_output"
    else
      printf "\033[2;36m  idle (no loaded output)\033[0m\n"
    fi
  else
    printf "  ollama not installed\n"
  fi

  printf "\n\033[36mInstalled models:\033[0m\n"
  if command -v ollama >/dev/null 2>&1; then
    _list_output="$(ollama list 2>/dev/null)"
    _list_rows="$(printf '%s\n' "$_list_output" | sed '/^NAME[[:space:]]/d;/^[[:space:]]*$/d')"
    if [ -n "$_list_rows" ]; then
      if [ -n "${_active_names:-}" ] && printf '%s\n' "$_active_names" | grep -Fxf <(printf '%s\n' "$_list_rows" | awk '{print $1}') >/dev/null 2>&1; then
        _active_installed_match=1
      fi
      _installed_count="$(printf '%s\n' "$_list_rows" | wc -l | tr -d ' ')"
      if [ "$_active_installed_match" -eq 1 ]; then
        printf "\033[1;95m  %s installed (active model present)\033[0m\n" "$_installed_count"
      else
        printf "\033[32m  %s installed\033[0m\n" "$_installed_count"
      fi
      _list_header="$(printf '%s\n' "$_list_output" | sed -n '1p')"
      printf "%s\n" "$_list_header"
      while IFS= read -r _list_line; do
        _list_name="$(printf '%s\n' "$_list_line" | awk '{print $1}')"
        if [ -n "${_active_names:-}" ] && printf '%s\n' "$_active_names" | grep -Fxq "$_list_name"; then
          printf "\033[1;95m%s\033[0m\n" "$_list_line"
        else
          printf "%s\n" "$_list_line"
        fi
      done <<EOF
$(printf '%s\n' "$_list_rows")
EOF
    elif [ -n "$_list_output" ]; then
      printf "\033[33m  0 installed models\033[0m\n"
      printf "%s\n" "$_list_output"
    else
      printf "  none installed\n"
    fi
  else
    printf "  ollama not installed\n"
  fi

  printf "\n\033[36mQuick actions:\033[0m\n"
  printf "  ollama ps\n"
  printf "  ollama list\n"
  printf "  journalctl -u ollama -f\n"
  printf "  systemctl status ollama --no-pager\n"
  printf "  nvidia-smi\n"
  printf "\n\033[36mTips:\033[0m\n"
  printf "  Left pane starts in model chat\n"
  printf "  >>> means you are talking to a model\n"
  printf "  Ctrl+D or /bye returns to shell\n"
  printf "  From shell: oc | qc | og | ov\n"
  printf "  Bottom-right pane is always shell\n"
  printf "\n\033[38;5;244mRefreshes every 3s. Press Ctrl+C to open a shell.\033[0m\n"
}

if [ "${OLLAMA_HELPER_ONCE:-0}" = "1" ]; then
  render
  exit 0
fi

trap 'printf "\n"; exec zsh -il' INT

while true; do
  render
  sleep 3
done
